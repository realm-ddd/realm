module Realm
  module Messaging
    class MessageFactory
      def initialize(message_type_factory = MessageType, system_name: nil, &builder_block)
        @message_type_factory = message_type_factory
        @message_types        = Hash.new
        @system_name          = system_name

        builder_block[self] if block_given?
      end

      def define(message_type_name, definition = { })
        # We have to use merge to pass the system_name keyword arg below due to the way Ruby behaves
        @message_types[message_type_name] =
          @message_type_factory.new(message_type_name, definition.merge(system_name: @system_name))
      end

      def build(message_type_name, attributes = { })
        message_type = @message_types.fetch(message_type_name) do
          raise UnknownMessageTypeError.new(%Q'Unknown MessageType: "#{message_type_name}"')
        end

        message_type.new_message(attributes)
      end

      def determine_responses_to(message_type_name, from: required(:from))
        originating_message_type =
          @message_types.fetch(message_type_name) {
            raise UnknownMessageTypeError.new(message_type_name)
          }

        from.select_message_types { |candidate_response|
          candidate_response.response_to?(originating_message_type)
        }
      end

      def select_message_types(&filter)
        @message_types.inject({ }) { |result, (message_type_name, message_type)|
          result[message_type_name] = message_type if filter[message_type]
          result
        }
      end
    end
  end
end
