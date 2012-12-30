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
    Celluloid.logger.level = Logger::ERROR
    server = Pry::Notebook::Server.new(host, port)
    yield server
  ensure
    server && server.terminate
  end

  it "should serve the home page via GET" do
    with_server do
      response = Net::HTTP.get url
      response.must_equal \
        File.read(File.expand_path("../../../public/index.html", __FILE__))
    end
  end

  it "should accept input for Pry via POST" do
    Pry::Notebook::Pry.any_instance.expects(:eval).with('puts "hey & baby"')

    with_server do
      http = Net::HTTP.new(url.host, url.port)
      http.post url.path, 'puts "hey & baby"'
    end
  end
end
