require 'forwardable'

module Realm
  module Domain
    module Validation
      # This is really only a sanity check using a simple regex.
      # It could also be implemented by just delegating to a RegexValidator.
      class EmailValidator
        def initialize(name: required(:name))
          @regex = /[^\s@]@[^\s.]+\.[^\s.]/
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
