module Realm
  module Messaging
    class UnhandledMessageError < RuntimeError
      attr_reader :domain_message

      def initialize(domain_message)
        @domain_message = domain_message
      end

      def message
        "Unhandled message: " + @domain_message.to_s
      end
    end
  end
end