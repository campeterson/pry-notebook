# encoding: utf-8

module Pry::Notebook
  class Pry
    attr_reader :output

    def initialize(options)
      @output = options.delete :output
      @pry    = ::Pry.new

      @pry.callbacks.handle_result = proc do |result|
        formatted_result = result.inspect

        @output << { type: :result, value: formatted_result }
      end

      @pry.callbacks.handle_error = proc do |error|
        message   = "#{error.class}: #{error.message}"
        backtrace = error.backtrace.join("\n")

        @output << { type: :error, value: message, backtrace: backtrace}
      end
    end

    def eval(str)
      @pry.eval str
    end
  end
end
