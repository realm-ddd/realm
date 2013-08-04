require 'term/ansicolor'

module Realm
  module Messaging
    module Formatting
      class PrettyTerminalMessageFormatter
        include Term::ANSIColor

        class << self
          def inspector
            # Don't care about race conditions
            @inspector ||=
              AwesomePrint::Inspector.new(
                multiline: false,
                sort_keys: true
              )
          end
        end

        def format(attrs)
          # inspector.awesome(message_attributes)
          "<" <<
            cyan(attrs.fetch(:category).to_s) << " " <<
            "type=" << magenta(attrs.fetch(:type).to_s) << " " <<
            "version=" << attrs.fetch(:version).to_s << " " <<
            "timestamp=" << attrs.fetch(:timestamp).inspect << " " <<
            "attributes={" << attributes_string(attrs.fetch(:attributes)) << "}" <<
          ">"
        end

        private

        def attributes_string(attributes)
          attributes.map { |property, attribute|
            magenta(property.to_s) << ": " << inspector.awesome(attribute)
          }.join(", ")
        end

        def inspector
          self.class.inspector
        end
      end
    end
  end
end