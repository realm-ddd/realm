require_relative 'validation_result'

module Realm
  module Domain
    module Validation
      class ValidatorStateError < RuntimeError; end

      class CommandValidator
        def initialize(validators: { }, messages: { })
          @validators = validators
          @messages   = messages
        end

        def validate(command)
          ValidationResult.new do |result|
            @validators.each do |property, validator|
              attribute_result = validator.validate(command.send(property))
              if !attribute_result.valid?
                result.invalid
                result.add_message(@messages.fetch(property))
              end
            end
          end
        end
      end
    end
  end
end
