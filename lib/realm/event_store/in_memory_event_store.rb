module Realm
  module EventStore
    class InMemoryEventStore
      include EventStore
      def initialize(event_bus)
        @event_bus = event_bus
        reset
      end

      # Hack for Cucumber
      def reset
        @events = Hash.new { |hash, uuid| hash[uuid] = [ ] }
      end

      def save_events(uuid, events)
        events.each do |event|
          @event_bus.publish(event)
          @events[uuid] << event
        end
      end

      def history_for_aggregate(uuid)
        @events.fetch(uuid) do
          raise UnknownAggregateRootError.new(uuid)
        end.dup
      end
    end
  end
end
