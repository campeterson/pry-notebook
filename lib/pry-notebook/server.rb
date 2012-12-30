require 'reel'
require 'json'

module Pry::Notebook
  class Server < Reel::Server
    class MultiOutput
      attr_reader :subscribers

      def initialize
        @subscribers = []
      end

      def <<(obj)
        @subscribers.each do |s|
          s << obj
        end
      end

      def register(subscriber)
        @subscribers << subscriber
      end
    end

    class Client
      include Celluloid
      include Celluloid::Logger

      def initialize(socket, multi_output)
        @socket = socket
        multi_output.register self
      end

      def <<(obj)
        @socket << JSON.dump(obj)
      rescue Reel::SocketError
        info "Client disconnected"
        terminate
      end
    end

    include Celluloid::Logger

    def initialize(host = "127.0.0.1", port = 1234)
      @pry = ::Pry::Notebook::Pry.new(output: MultiOutput.new)

      info "Pry::Notebook starting on #{host}:#{port}"
      super(host, port, &method(:on_connection))
    end

    def on_connection(connection)
      while request = connection.request
        case request
        when Reel::Request
          case request.method.to_s
          when "post"
          when "get"
            connection.respond :ok, public_file("/index.html")
          end
        when Reel::WebSocket
          info "Received a WebSocket connection"
          Client.new(socket, @pry.output)
        end
      end
    end

    def public_file(path)
      File.read(File.expand_path("../../../public#{path}", __FILE__))
    end
  end
end
