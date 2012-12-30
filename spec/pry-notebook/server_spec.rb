# encoding: UTF-8

require "helper"
require "net/http"

describe Pry::Notebook::Server do
  def host; "127.0.0.1" end
  def port; 2345        end

  def url(path = "/")
    URI.parse("http://#{host}:#{port}#{path}")
  end

  it "should serve the home page via GET" do
    with_server(host, port) do
      response = Net::HTTP.get url
      response.must_include "<html>"
    end
  end

  it "should accept input for Pry via POST" do
    Pry::Notebook::Pry.any_instance.expects(:eval).with('puts "hey & baby"')

    with_server(host, port) do
      http = Net::HTTP.new(url.host, url.port)
      http.post url.path, 'puts "hey & baby"'
    end
  end

  it "should send return values via socket" do
    with_server(host, port) do
      with_websocket do |client|
        http = Net::HTTP.new(url.host, url.port)
        http.post url.path, '10'

        get_message(client).must_equal "type" => "result", "value" => "10"
      end
    end
  end
end
