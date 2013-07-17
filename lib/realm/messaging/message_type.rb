module Realm
  module Messaging
    class MessageType
      GENERIC_PROPERTIES = [ :message_type, :version, :timestamp, :uuid ].freeze

      def initialize(name, properties = [ ])
        @name = name
        @properties = GENERIC_PROPERTIES + properties
      end

      def new_message(attributes)
        augmented_attributes = augment_attributes(attributes)

        unless augmented_attributes.keys.sort == @properties.sort
          raise MessagePropertyError.new(@name, @properties, augmented_attributes.keys)
        end

        Message.new(augmented_attributes)
      end

      private

      def augment_attributes(attributes)
        { timestamp: Time.now }.merge(attributes).merge(message_type: @name, version: 1)
      end
    end
  end
end