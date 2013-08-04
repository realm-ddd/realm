require 'term/ansicolor'

module Realm
  module Messaging
    module Formatting
      class PrettyTerminalMessageFormatter
        include Term::ANSIColor

        # Because of the way AwesomePrint manages thread concurrency,
        # we have to have something we can initialize for each format run
        class PrettyAwesomeFormatter
          include Term::ANSIColor

          def initialize(inspector)
            @inspector = inspector
          end

          def attributes_string(attributes)
            attributes.map { |property, attribute|
              magenta(property.to_s) << ": " << @inspector.awesome(attribute)
            }.join(", ")
          end
        end

        def format(attrs)
          attributes_string =
            new_attributes_formatter.attributes_string(
              attrs.fetch(:attributes)
            )

          "<" <<
            cyan(attrs.fetch(:category).to_s) << " " <<
            "type=" << magenta(attrs.fetch(:type).to_s) << " " <<
            "version=" << attrs.fetch(:version).to_s << " " <<
            "timestamp=" << attrs.fetch(:timestamp).inspect << " " <<
            "attributes={" << attributes_string << "}" <<
          ">"
        end

        private

        def new_attributes_formatter
          PrettyAwesomeFormatter.new(new_inspector)
        end

        def new_inspector
          AwesomePrint::Inspector.new(
            multiline: false,
            sort_keys: true
          )
        end
      end
    end
  end
end