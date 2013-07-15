module Realm
	module Bus
		class SimpleEventBus
			include EventBus

			def initialize
				@handlers = Hash.new { |hash, key| hash[key] = [ ] }
			end

			def register(event_type, *handlers)
				@handlers[event_type.to_sym].concat(handlers)
			end

			def publish(event)
				event_type = event.event_type

				if have_handlers_for?(event_type)
					publish_event_to_handlers(event, handlers_for_event_type(event_type))
				else
					publish_event_to_unhandled_event_handlers(event)
				end
			end

			private

			def publish_event_to_handlers(event, handlers)
				handlers.each do |handler|
					handler.send(:"handle_#{event.event_type}", event)
				end
			end

			def publish_event_to_unhandled_event_handlers(event)
				@handlers[:unhandled_event].each do |handler|
					handler.handle_unhandled_event(event)
				end
			end

			def have_handlers_for?(event_type)
				handlers_for_event_type(event_type).length > 0
			end

			def handlers_for_event_type(event_type)
				@handlers[event_type] + @handlers[:all_events]
			end
		end
	end
end
