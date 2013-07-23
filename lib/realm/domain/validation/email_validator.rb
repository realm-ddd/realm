require_relative 'validation_result'

module Realm
  module Domain
    module Validation
      class EmailValidator
        def initialize
          @regex_validator = RegexValidator.new(/[^\s@]@[^\s.]+\.[^\s.]/)
        end

        def validate(value)
          @regex_validator.validate(value)
        end
      end
    end
  end
end
