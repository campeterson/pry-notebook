require 'reel'

module Pry::Notebook
  class Server < Reel::Server
    include Celluloid::Logger

    def initialize(host = "127.0.0.1", port = 1234)
      info "Pry::Notebook starting on #{host}:#{port}"
      super(host, port, &method(:on_connection))
    end

    def on_connection(connection)
      info "Opened connection: #{connection}"
      connection.respond :ok, "OK"
    end
  end
end
