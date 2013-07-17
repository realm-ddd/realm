module Realm
  module Messaging
    module Bus
      class UnhandledMessageErrorRaiser
        class UnhandledMessageError < RuntimeError; end

        def handle_unhandled_message(message)
          raise UnhandledMessageError.new("Unhandled message: " + message.to_s)
        end
      end
    end
  end
end