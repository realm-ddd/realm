module Realm
  module Messaging
    class NoResponsesFoundError < MessagingError
      def initialize(message_type_name)
        super("No responses found for message type #{message_type_name.inspect}")
      end
    end
  end
end