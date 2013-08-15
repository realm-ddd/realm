module Realm
  module Messaging
    class UnhandledMessageError < MessagingError
      attr_reader :domain_message

      class PretendSymbolIsAMessage
        def initialize(symbol)
          @symbol = symbol
        end

        def to_s
          @symbol.inspect
        end

        def message_type_name
          @symbol
        end
      end

      def initialize(message)
        @domain_message = wrap_message(message)
      end

      def message
        "Unhandled message: " + @domain_message.to_s
      end

      def message_type_name
        @domain_message.message_type_name
      end

      private

      def wrap_message(message)
        case message
        when Message then message
        when Symbol   then PretendSymbolIsAMessage.new(message)
        else message # Probably a mock
        end
      end
    end
  end
end