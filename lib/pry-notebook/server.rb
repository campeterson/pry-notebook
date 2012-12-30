require 'reel'
require 'json'

module Pry::Notebook
  class Server < Reel::Server
    class Client
      include Celluloid
      include Celluloid::Logger

      def initialize(socket, pry)
        @socket = socket
        @pry    = pry

        @pry.subscribe self.object_id, self
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
            @pry.eval request.body
            connection.respond :ok, "OK"
          when "get"
            connection.respond :ok, public_file("/index.html")
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
  end
end
