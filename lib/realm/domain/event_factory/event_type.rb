module Realm
  module Domain
    class EventFactory
      class EventType
        GENERIC_PROPERTIES = [ :event_type, :version, :timestamp, :uuid ].freeze

        def initialize(name, properties = [ ])
          @name = name
          @properties = GENERIC_PROPERTIES + properties
        end

        def new_event(attributes)
          augmented_attributes = augment_attributes(attributes)

          unless augmented_attributes.keys.sort == @properties.sort
            raise EventPropertyError.new(@name, @properties, augmented_attributes.keys)
          end

          Event.new(augmented_attributes)
        end

        private

        def augment_attributes(attributes)
          { timestamp: Time.now }.merge(attributes).merge(event_type: @name, version: 1)
        end
      end
    end
  end
end