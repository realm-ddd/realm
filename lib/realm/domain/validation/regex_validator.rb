require_relative 'validation_result'

module Realm
  module Domain
    module Validation
      class RegexValidator
        def initialize(regex)
          @regex = regex
        end

        def validate(value)
          ValidationResult.new do |result|
            result.invalid unless @regex.match(value)
          end
        end
      end
    end
  end
end
