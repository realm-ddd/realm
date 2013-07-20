module Realm
  module Messaging
    module Bus
      class UnhandledMessageSentinel
        def handle_unhandled_message(message)
          raise UnhandledMessageError.new(message)
        end
      end
    end
  end
end