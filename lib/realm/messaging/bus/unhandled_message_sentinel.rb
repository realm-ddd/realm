module Realm
  module Messaging
    module Bus
      # This handler is not an actor because calling it asynchronously
      # would not crash the message bus (which is the intent)
      class UnhandledMessageSentinel
        def handle_unhandled_message(message)
          raise UnhandledMessageError.new(message)
        end
      end
    end
  end
end