# encoding: UTF-8

require "helper"
require "net/http"

describe Pry::Notebook::Server do
  def host; "127.0.0.1" end
  def port; 2345        end

  def url(path = "/")
    URI.parse("http://#{host}:#{port}#{path}")
  end

  def with_server
    Celluloid.logger = nil
    server = Pry::Notebook::Server.new(host, port)
    yield server
  ensure
    server && server.terminate
  end

  it "should respond to a non-WebSocket request" do
    with_server do
      response = Net::HTTP.get url
      response.must_equal "OK"
    end
  end
end
