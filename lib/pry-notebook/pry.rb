# encoding: utf-8

module Pry::Notebook
  class Pry
    class Output
      attr_accessor :handle_chunk

      def puts(str)
        print "#{str}\n"
      end

      def print(str)
        handle_chunk.call(str)
      end
      alias write print

      def tty?
        false
      end
    end

    attr_reader :output, :pry

    def initialize(options)
      @output = options.delete :output
      @pry    = ::Pry.new(:output => Output.new)

      @pry.callbacks.handle_result = proc do |result|
        formatted_result = result.inspect

        @output << { type: :result, value: formatted_result }
      end

      @pry.callbacks.handle_error = proc do |error|
        message   = "#{error.class}: #{error.message}"
        backtrace = error.backtrace.join("\n")

        @output << { type: :error, value: message, backtrace: backtrace }
      end

      @pry.output.handle_chunk = proc do |string|
        @output << { type: :output, value: string }
      end

      # Temp until better config system
      ::Pry.config.color = false
    end

    def eval(str)
      out     = $stdout
      $stdout = @pry.output
      @pry.eval str
    ensure
      $stdout = out
    end
  end
end
