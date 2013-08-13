require 'celluloid'

module Realm
  module Messaging
    # If you use this, don't forget to terminate it
    class Result
      include Celluloid

      def initialize
        @message_type = nil
        @message_args = nil
        @value_ready = false

        @condition = Celluloid::Condition.new
      end

      def on(handlers)
        @condition.wait unless @value_ready

        if !handlers.has_key?(@message_type)
          abort UnhandledMessageError.new(@message_type)
        end

        begin
          handlers.fetch(@message_type).call(*@message_args)
        rescue ArgumentError => e
          abort e
        end
      end

      # Hacky way of handling messages while we don't have an explicit
      # definition of response messages
      def method_missing(message_name, *args)
        @message_type = message_name
        @message_args = args
        @value_ready = true

        # We have only one listener, but Celluloid complains if you
        # signal a condition that has no tasks waiting on it
        @condition.broadcast
      end
    end
  end
end