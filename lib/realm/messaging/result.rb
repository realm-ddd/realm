require 'celluloid'

module Realm
  module Messaging
    # If you use this, don't forget to terminate it
    class Result
      include Celluloid

      def initialize(responses: r(:responses))
        @responses = responses

        @message_type_name  = nil
        @message_args       = nil
        @value_ready        = false

        @condition = Celluloid::Condition.new
      end

      def understand_response?(response_message_name)
        @responses.has_key?(response_message_name)
      end

      def on(handlers)
        @condition.wait unless @value_ready

        handlers.each do |message_type_name, handler|
          if !@responses.has_key?(message_type_name)
            abort UnknownMessageTypeError.new(message_type_name)
          end
        end

        if !handlers.has_key?(@message_type_name)
          abort UnhandledMessageError.new(@message_type_name)
        end

        begin
          handlers.fetch(@message_type_name).call(*@message_args)
        rescue ArgumentError => e
          abort e
        end
      end

      # Hacky way of handling messages while we don't have an explicit
      # definition of response messages
      def method_missing(message_type_name, *args)
        if !@responses.has_key?(message_type_name)
          abort UnhandledMessageError.new(message_type_name)
        end

        # Assumes we got one argument, and also that #new_messages raises an error...
        # (Maybe we should have have an `assert_valid_message` method instead
        begin
          @responses[message_type_name].new_message(args.first)
        rescue MessagingError => e
          abort e
        end

        @message_type_name  = message_type_name
        @message_args       = args
        @value_ready        = true

        # We have only one listener, but Celluloid complains if you
        # signal a condition that has no tasks waiting on it
        @condition.broadcast
      end

      def respond_to?(message_type_name, include_private = false)
        understand_response?(message_type_name) || super
      end
    end
  end
end