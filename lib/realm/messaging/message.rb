require 'facets/hash/join'
require 'facets/hash/op_sub'

module Realm
  module Messaging
    class Message
      attr_reader :system_name

      GENERIC_PROPERTIES = %i[
        message_type_name
        version
        timestamp
      ].freeze

      def initialize(attributes, system_name: nil)
        @attributes = sanitize_attributes(attributes)
        @system_name = system_name
      end

      def to_s
        %Q{<Message type="#{@attributes[:message_type_name]}" attributes=[#{attributes_to_s}]>}
      end

      def output_to(formatter)
        formatter.format(to_h)
      end

      def matches?(message_description)
        assert_valid_message_description(message_description)

        our_attributes, comparison_attributes =
          prepare_attributes_for_match(@attributes.dup, message_description.dup)

        our_attributes == comparison_attributes
      end

      def respond_to?(message_type_name)
        @attributes.has_key?(message_type_name) || super
      end

      private

      # Maybe one day we'll pre-generate classes for each message type, but not now
      def method_missing(name, *args)
        @attributes.fetch(name) do
          super(name, *args)
        end
      end

      def to_h
        {
          category:   :message,
          type:       @attributes.fetch(:message_type_name),
          version:    @attributes.fetch(:version),
          timestamp:  @attributes.fetch(:timestamp),
          attributes: message_specific_attributes
        }
      end

      def message_specific_attributes
        @attributes.reject { |key, value| GENERIC_PROPERTIES.include?(key) }
      end

      def sanitize_attributes(attributes)
        attributes.merge(message_type_name: attributes[:message_type_name].to_sym)
      end

      def attributes_to_s
        @attributes.inject({ }) { |hash, (key, value)|
          hash[key] = value.inspect
          hash
        }.join(": ", ", ")
      end

      def assert_valid_message_description(message_description)
        if !message_description.has_key?(:message_type_name)
          raise ArgumentError.new("Message descriptions must include a :message_type_name key")
        end

        return unless message_type_name == message_description[:message_type_name]

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