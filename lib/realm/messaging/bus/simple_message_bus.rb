module Realm
  module Messaging
    module Bus
      class SimpleMessageBus
        include MessageBus

        def initialize
          @handlers = Hash.new { |hash, key| hash[key] = [ ] }
        end

        def register(message_type, *handlers)
          @handlers[message_type.to_sym].concat(handlers)
        end

        def publish(message)
          message_type = message.message_type

          if have_handlers_for?(message_type)
            publish_message_to_handlers(message, handlers_for_message_type(message_type))
          else
            publish_message_to_unhandled_message_handlers(message)
          end
        end

        private

        def publish_message_to_handlers(message, handlers)
          handlers.each do |handler|
            handler.send(:"handle_#{message.message_type}", message)
          end
        end

        def publish_message_to_unhandled_message_handlers(message)
          @handlers[:unhandled_message].each do |handler|
            handler.handle_unhandled_message(message)
          end
        end

        def have_handlers_for?(message_type)
          handlers_for_message_type(message_type).length > 0
        end

        def handlers_for_message_type(message_type)
          @handlers[message_type] + @handlers[:all_messages]
        end
      end
    end
  end
end
