module Realm
  module Messaging
    class NoResponsesFoundError < MessagingError
      def initialize(message_name)
        super("No responses found for message type #{message_name.inspect}")
      end
    end
  end
end