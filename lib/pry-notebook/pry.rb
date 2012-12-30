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

    attr_reader :output

    def initialize
      @pry         = ::Pry.new(:output => Output.new)
      @output      = @pry.output
      @subscribers = {}

      @pry.callbacks.handle_result = proc do |result|
        formatted_result = result.inspect

        publish type: :result, value: formatted_result
      end

      @pry.callbacks.handle_error = proc do |error|
        message   = "#{error.class}: #{error.message}"
        backtrace = error.backtrace.join("\n")

        publish type: :error, value: message, backtrace: backtrace
      end

      @output.handle_chunk = proc do |string|
        publish type: :output, value: string
      end

      # Temp until better config system
      ::Pry.config.color = false
    end

    def publish(event)
      @subscribers.each do |_, pipe|
        pipe << event
      end
    end

    def subscribe(identifier, receiver = [])
      @subscribers[identifier] = receiver
    end

    def unsubscribe(identifier)
      @subscribers[identifier] = nil
    end

    def eval(str)
      out     = $stdout
      $stdout = @output
      @pry.eval str
    ensure
      $stdout = out
    end
  end
end
