module Realm
  module Messaging
    class UnknownMessageTypeError < MessagingError
      def initialize(message_name)
        super("Unknown message type #{message_name.inspect}")
      end
    end
  end
end