require 'facets/hash/join'
require 'facets/hash/op_sub'

module Realm
  module Messaging
    class Message
      def initialize(attributes)
        @attributes = sanitize_attributes(attributes)
      end

      def to_s
        %Q{<Message type="#{@attributes[:message_type]}" attributes=[#{attributes_to_s}]>}
      end

      def matches?(message_description)
        assert_valid_message_description(message_description)

        our_attributes, comparison_attributes =
          prepare_attributes_for_match(@attributes.dup, message_description.dup)

        our_attributes == comparison_attributes
      end

      private

      def method_missing(name, *args)
        @attributes.fetch(name) do
          super(name, *args)
        end
      end

      def sanitize_attributes(attributes)
        attributes.merge(message_type: attributes[:message_type].to_sym)
      end

      def attributes_to_s
        @attributes.inject({ }) { |hash, (key, value)|
          hash[key] = value.inspect
          hash
        }.join(": ", ", ")
      end

      def assert_valid_message_description(message_description)
        if !message_description.has_key?(:message_type)
          raise ArgumentError.new("Message descriptions must include a :message_type key")
        end

        return unless message_type == message_description[:message_type]

        if !(unknown_properties = message_description.keys - @attributes.keys).empty?
          raise ArgumentError.new("Unknown Message properties: #{unknown_properties.join(", ")}")
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