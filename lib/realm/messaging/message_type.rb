module Realm
  module Messaging
    class MessageType
      attr_reader :name

      # Note: we pass system_name through too, but we don't treat it as a property yet,
      # not until I've decided it is a property in the same way message_type_name etc are
      GENERIC_PROPERTIES = {
        message_type_name:  Symbol,
        version:            Integer,
        timestamp:          Time
      }.freeze

      # Properties are specified as `name => type` but currently we ignore the type
      # Responses can be specified but currently don't do anything (to be added soon)
      def initialize(name, properties: { }, responses: [ ], system_name: nil)
        @name         = name
        @properties   = GENERIC_PROPERTIES.merge(properties)
        @responses    = responses
        @system_name  = system_name
      end

      def new_message(attributes)
        augmented_attributes = augment_attributes(attributes)

        unless augmented_attributes.keys.sort == property_names.sort
          raise MessagePropertyError.new(@name, property_names, augmented_attributes.keys)
        end

        Message.new(augmented_attributes, system_name: @system_name)
      end

      def response_to?(target)
        target.accept_as_response?(@name)
      end

      def accept_as_response?(message_type_name)
        @responses.include?(message_type_name)
      end

      private

      def augment_attributes(attributes)
        { timestamp: Time.now }.merge(attributes).merge(message_type_name: @name, version: 1)
      end

      def property_names
        @properties.keys
      end
    end
  end
end