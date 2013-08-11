module Realm
  module Messaging
    # A synchronous message response that will resolve immediately to
    # the pre-determined response message
    class FakeMessageResponse
      def initialize(resolve_with: required(:resolve_with))
        @response_message = resolve_with.fetch(:message_name)
        @response_args    = resolve_with.fetch(:args)
      end

      def on(handlers)
        if !handlers.has_key?(@response_message)
          raise UnhandledMessageError.new(@response_message)
        end

        handler = handlers[@response_message]

        if @response_args.is_a?(Array)
          handler.call(*@response_args)
        else
          handler.call(@response_args)
        end
      end
    end
  end
end
