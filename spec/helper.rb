# encoding: utf-8

require "minitest/spec"
require "minitest/autorun"
require "minitest/pride"

require "mocha/setup"

require "pry-notebook"

Celluloid.logger.level = Logger::ERROR

def with_server(host, port)
  server = Pry::Notebook::Server.new(host, port)
  yield server
ensure
  server && server.terminate
end

def with_websocket
  client = TCPSocket.new(host, port)
  client << handshake.to_data
  client.readpartial(4096) # discard handshake
  yield client
ensure
  client && client.close rescue nil
end

def handshake_headers
  {
    "Host"                   => host,
    "Upgrade"                => "websocket",
    "Connection"             => "Upgrade",
    "Sec-WebSocket-Key"      => "dGhlIHNhbXBsZSBub25jZQ==",
    "Origin"                 => "http://example.com",
    "Sec-WebSocket-Protocol" => "chat, superchat",
    "Sec-WebSocket-Version"  => "13"
  }
end

def handshake
  WebSocket::ClientHandshake.new(:get, url.to_s, handshake_headers)
end

def get_message(socket)
  parser  = WebSocket::Parser.new
  message = nil

  parser.on_message do |m|
    message = m
  end

  while message.nil?
    parser << socket.read(1)
  end

  JSON.load message
end
