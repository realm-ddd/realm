module Realm
  module Messaging
    # A synchronous message response that will resolve immediately to
    # the pre-determined response message
    class FakeMessageResponse
      class MessageResponse
        def initialize(message_type_name, args)
          @response_message = message_type_name
          @response_args    = args
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

      class ErrorResponse
        def initialize(error)
          @error = error
        end

        def on(*)
          raise @error
        end
      end

      def initialize(resolve_with: nil, raise_error: nil)
        @response =
          if resolve_with
            MessageResponse.new(resolve_with.fetch(:message_type_name), resolve_with.fetch(:args))
          elsif raise_error
            ErrorResponse.new(raise_error)
          else
            raise ArgumentError.new("You must provide either a respond_with: or a raise_error: argument")
          end
      end

      def on(handlers)
        @response.on(handlers)
      end
    end
  end
end
