module Realm
  module Messaging
    class UnknownMessageTypeError < MessagingError
      def initialize(message_type_name)
        super("Unknown message type #{message_type_name.inspect}")
      end
    end
  end
end