module Realm
  module Messaging
    class MessageType
      GENERIC_PROPERTIES = {
        message_type: Symbol,
        version:      Integer,
        timestamp:    Time
      }.freeze

      # Properties are specified as `name => type` but currently we ignore the type
      # Responses can be specified but currently don't do anything (to be added soon)
      def initialize(name, properties: { }, responses: [ ])
        @name = name
        @properties = GENERIC_PROPERTIES.merge(properties)
      end

      def new_message(attributes)
        augmented_attributes = augment_attributes(attributes)

        unless augmented_attributes.keys.sort == property_names.sort
          raise MessagePropertyError.new(@name, property_names, augmented_attributes.keys)
        end

        Message.new(augmented_attributes)
      end

      private

      def augment_attributes(attributes)
        { timestamp: Time.now }.merge(attributes).merge(message_type: @name, version: 1)
      end

      def property_names
        @properties.keys
      end
    end
  end
end