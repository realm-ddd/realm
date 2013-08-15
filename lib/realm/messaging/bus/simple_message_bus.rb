module Realm
  module Messaging
    module Bus
      class NoResultFactoryAvailableError < MessagingError; end

      class NullResultFactory
        def new_unresolved_result(*)
          raise NoResultFactoryAvailableError.new("A MessageBus must be constructed with a ResultFactory to send messages that require a response")
        end
      end

      class SimpleMessageBus
        include MessageBus

        class TooManyMessageHandlersError < MessagingError; end

        def initialize(
            result_factory:         NullResultFactory.new,
            unhandled_send_handler: UnhandledMessageSentinel.new
          )

          @result_factory = result_factory

          @handlers = Hash.new { |hash, key| hash[key] = [ ] }
          @unhandled_send_handler = unhandled_send_handler
        end

        def register(message_type, *handlers)
          @handlers[message_type.to_sym].concat(handlers)
          self
        end

        # Send to a single registered handler
        # It would probably be much better if we just prevented registering multiple handlers
        # for messages of certain types (or add message categories, and make this apply to all
        # command category messages)
        def send(message)
          result = @result_factory.new_unresolved_result(message)

          message_type = message.message_type
          explicit_handlers = explicit_handlers_for_message_type(message_type)

          if explicit_handlers.length == 0
            @unhandled_send_handler.handle_unhandled_message(message)
          elsif explicit_handlers.length == 1
            explicit_handlers.first.send(:"handle_#{message.message_type}", message, response_port: result)
          else
            raise TooManyMessageHandlersError.new(
              %'Found #{explicit_handlers.length} message handlers for "#{message_type}": #{explicit_handlers.inspect}'
            )
          end

          publish_message_to_handlers(message, handlers_for_all_messages)

          result
        end

        # Broadcast
        def publish(message)
          message_type = message.message_type

          if have_handlers_for?(message_type)
            publish_message_to_handlers(message, handlers_for_message_type(message_type))
          else
            publish_message_to_unhandled_message_handlers(message)
          end

          nil
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
          explicit_handlers_for_message_type(message_type) + handlers_for_all_messages
        end

        def explicit_handlers_for_message_type(message_type)
          @handlers[message_type]
        end

        def handlers_for_all_messages
          @handlers[:all_messages]
        end
      end
    end
  end
end
