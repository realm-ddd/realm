module Realm
  module Messaging
    module Bus
      class SimpleMessageBus
        include MessageBus

        class TooManyMessageHandlersError < RuntimeError; end

        def initialize(unhandled_send_handler: UnhandledMessageSentinel.new)
          @handlers = Hash.new { |hash, key| hash[key] = [ ] }
          @unhandled_send_handler = unhandled_send_handler
        end

        def register(message_type, *handlers)
          @handlers[message_type.to_sym].concat(handlers)
        end

        # Send to a single registered handler
        # It would probably be much better if we just prevented registering multiple handlers
        # for messages of certain types (or add message categories, and make this apply to all
        # command category messages)
        def send(message)
          message_type = message.message_type
          handlers = handlers_for_message_type(message_type)

          if handlers.length == 0
            @unhandled_send_handler.handle_unhandled_message(message)
          elsif handlers.length == 1
            publish_message_to_handler(message, handlers.first)
          else
            raise TooManyMessageHandlersError.new(
              %'Found #{handlers.length} message handlers for "#{message_type}": #{handlers.inspect}'
            )
          end
        end

        # Broadcast
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
            publish_message_to_handler(message, handler)
          end
        end

        def publish_message_to_handler(message, handler)
          handler.send(:"handle_#{message.message_type}", message)
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
