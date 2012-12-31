require 'reel'
require 'json'
require 'rack/builder'

require 'pry-notebook/pry'

module Pry::Notebook
  class Pry
    include Celluloid
  end

  class Server < Reel::Server
    class Client
      include Celluloid
      include Celluloid::Logger

      def initialize(socket, pry)
        @socket = socket
        @pry    = pry.async

        @pry.subscribe self.object_id, self.async
      end

      def <<(obj)
        @socket << JSON.dump(obj)
      rescue Reel::SocketError
        info "Client disconnected"
        terminate
      end

      def terminate(*)
        super
      ensure
        @pry.unsubscribe self.object_id
      end
    end

    GetHandler = Rack::Builder.new do
      use Rack::Static,
        urls: [""],
        root: File.expand_path("../files", __FILE__),
        index: "index.html"
      run proc { |env| [404, {}, ["Not Found"]] }
    end

    include Celluloid::Logger

    def initialize(host = "127.0.0.1", port = 1234, capture_all = false)
      @pry = ::Pry::Notebook::Pry.new

      if capture_all
        $stdout = @pry.output
      end

      info "Pry::Notebook starting on #{host}:#{port}"
      super(host, port, &method(:on_connection))
    end

    def on_connection(connection)
      while request = connection.request
        case request
        when Reel::Request
          case request.method.to_s
          when "post"
            info "Evaluating #{request.body.inspect}"
            @pry.async.eval request.body
            connection.respond :ok, "OK"
          when "get"
            resp   = GetHandler.call(rack_env(request))
            result = ""
            resp[2].each { |p| result << p }
            code   = resp[0] == 200 ? :ok : :not_found
            connection.respond code, result
          end
        when Reel::WebSocket
          info "Received a WebSocket connection"
          Client.new(request, @pry)
        end
      end
    end

    def public_file(path)
      File.read(File.expand_path("../../../public#{path}", __FILE__))
    end

    def rack_env(request)
      env = Hash[Reel::RackWorker::PROTO_RACK_ENV]
      env['HTTP_VERSION']   = request.version
      env['REQUEST_METHOD'] = request.method.to_s.upcase
      env['PATH_INFO']      = request.path
      env['QUERY_STRING']   = request.query_string || ''
      env
    end
  end
end
