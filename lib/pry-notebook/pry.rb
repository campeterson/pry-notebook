# encoding: utf-8

module Pry::Notebook
  class Pry
    attr_reader :output

    def initialize(options)
      @output = options.delete :output
      @pry    = ::Pry.new

      @pry.callbacks.handle_result = proc do |result|
        @output << { type: :result, value: result }
      end

      @pry.callbacks.handle_error = proc do |error|
        @output << { type: :error,  value: error }
      end
    end

    def eval(str)
      @pry.eval str
    end
  end
end
