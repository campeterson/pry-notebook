# encoding: utf-8

module Pry::Notebook
  class App < Sinatra::App
    def initialize
      @pry = Pry::Notebook::Pry.new
    end
  end
end
