module Realm
  module Domain
    module Validation
      class ValidationResult
        def initialize(&block)
          @valid = true
          @failure_messages = [ ]
          yield self if block_given?
        end

        def valid?
          @valid
        end

        def invalid?
          !@valid
        end

        def valid
          @valid = true
        end

        def invalid
          @valid = false
        end

        def add_message(message)
          @failure_messages << message
        end

        def message
          if invalid? && @failure_messages.any?
            @failure_messages.join("; ")
          end
        end
      end
    end
  end
end
