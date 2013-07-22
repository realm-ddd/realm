module Realm
  module Domain
    module Validation
      class RegexValidator
        def initialize(regex, name: required(:name))
          @regex = regex
          @name  = name
        end

        def dup_for_listener(listener)
          dup.tap do |new_validator|
            new_validator.send_notifications_to(listener)
          end
        end

        # Public, but you probably want to use the helper method above
        def send_notifications_to(listener)
          @listener = listener
        end

        def attribute_declared(property, attribute)
          if !@regex.match(attribute)
            @listener.attribute_failed_validation(property, @name)
          end
        end
      end
    end
  end
end
