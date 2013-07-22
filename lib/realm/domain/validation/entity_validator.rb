module Realm
  module Domain
    module Validation
      class ValidatorStateError < RuntimeError; end

      # This is an experimental approach to validation.
      #
      # This class has two protocols:
      # * The `validate` command and `entity_valid?` query used by clients
      # * The `attribute_declared` event used by validated entities
      #
      # The interaction between the two seems odd, somehow. We're not following
      # Tell Don't Ask here, as we expect clients to use us then query us (which
      # is why `entity_valid?` is different with and without using `validate`)
      class EntityValidator
        def initialize(validators: { }, messages: { })
          # Prototype state
          @validators = validators
          @messages   = messages

          # Lifecycle state
          @valid            = :prototype
          @failure_messages = [ ]
        end

        def validate(entity)
          check_not_prototype
          check_not_used

          @valid = true
          @validators.each do |property, validator|
            entity.send(:"declare_#{property}", validator)
          end
        end

        def entity_valid?
          @valid
        end

        def attribute_failed_validation(property, validation_name)
          @valid = false
          @failure_messages << @messages.fetch(property).fetch(validation_name)
        end

        def message
          return if @valid
          @failure_messages.join("; ")
        end

        private

        # This prototype check is convincing me we're constructing this object wrong
        def check_not_prototype
          if @valid == :prototype
            raise ValidatorStateError.new("Validator has not been prepared - use #dup first")
          end
        end

        def check_not_used
          raise "Validator has already been used" if @valid != :ready
        end

        def initialize_copy(prototype)
          @validators = @validators.inject({ }) { |new_validators, (property, validator)|
            new_validators[property] = validator.dup_for_listener(self)
            new_validators
          }
          @valid = :ready
        end
      end
    end
  end
end
