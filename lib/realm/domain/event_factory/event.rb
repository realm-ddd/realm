require 'facets/hash/join'
require 'facets/hash/op_sub'

module Realm
  module Domain
    class EventFactory
      class Event
        def initialize(attributes)
          @attributes = sanitize_attributes(attributes)
        end

        def to_s
          %Q{<Event type="#{@attributes[:event_type]}" attributes=[#{attributes_to_s}]>}
        end

        def matches?(event_description)
          assert_valid_event_description(event_description)

          our_attributes, comparison_attributes =
            prepare_attributes_for_match(@attributes.dup, event_description.dup)

          our_attributes == comparison_attributes
        end

        private

        def method_missing(name, *args)
          @attributes.fetch(name) do
            super(name, *args)
          end
        end

        def sanitize_attributes(attributes)
          attributes.merge(event_type: attributes[:event_type].to_sym)
        end

        def attributes_to_s
          @attributes.inject({ }) { |hash, (key, value)|
            hash[key] = value.inspect
            hash
          }.join(": ", ", ")
        end

        def assert_valid_event_description(event_description)
          if !event_description.has_key?(:event_type)
            raise ArgumentError.new("Event descriptions must include an :event_type key")
          end

          return unless event_type == event_description[:event_type]

          if !(unknown_properties = event_description.keys - @attributes.keys).empty?
            raise ArgumentError.new("Unknown Event properties: #{unknown_properties.join(", ")}")
          end
        end

        def prepare_attributes_for_match(ours, theirs)
          ours.delete(:timestamp)
          theirs.delete(:timestamp)

          ours.delete(:uuid)    if !theirs.has_key?(:uuid)
          ours.delete(:version) if !theirs.has_key?(:version)

          [ ours, theirs ]
        end
      end
    end
  end
end