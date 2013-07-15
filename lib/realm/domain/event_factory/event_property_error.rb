module Realm
  module Domain
    class EventFactory
      class EventPropertyError < ArgumentError
        def initialize(event_type_name, expected_properties, attribute_names)
          @event_type_name      = event_type_name
          @expected_properties  = expected_properties.sort
          @attribute_names      = attribute_names.sort
        end

        def message
          message = "Attributes did not match EventType(#{@event_type_name}) properties - "
          message << [unknown_properties, missing_attributes].compact.join("; ")
          message
        end

        private

        def unknown_properties
          named_difference("unknown properties", @attribute_names, @expected_properties)
        end

        def missing_attributes
          named_difference("missing attributes", @expected_properties, @attribute_names)
        end

        def named_difference(name, list_a, list_b)
          unless (difference = list_a - list_b).empty?
            "#{name}: #{difference.join(", ")}"
          end
        end
      end
    end
  end
end