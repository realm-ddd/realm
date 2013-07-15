module Realm; module Domain; class EventFactory; end; end; end

require_relative 'event_factory/event'
require_relative 'event_factory/event_property_error'
require_relative 'event_factory/event_type'

module Realm
  module Domain
    class EventFactory
      class UnknownEventType < ArgumentError; end

      def initialize(event_type_factory = EventType)
        @event_type_factory = event_type_factory
        @event_types = Hash.new
      end

      def define(event_type_name, *properties)
        @event_types[event_type_name] = @event_type_factory.new(event_type_name, properties)
      end

      def build(event_type_name, attributes = { })
        event_type = @event_types.fetch(event_type_name) do
          raise UnknownEventType.new(%Q'Unknown EventType: "#{event_type_name}"')
        end

        event_type.new_event(attributes)
      end
    end
  end
end
