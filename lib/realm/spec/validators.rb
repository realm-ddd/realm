require 'ostruct'

module Realm
  module Domain
    module Validation
      class AlwaysValidValidator
        def validate(target)
          @target = target
          OpenStruct.new(valid?: true, invalid?: false, message: nil)
        end

        def has_been_used_to_validate?(target)
          @target.equal?(target)
        end
      end

      class AlwaysInvalidValidator
        def initialize(message: required(:message))
          @message = message
        end

        def validate(target)
          @target = target
          OpenStruct.new(valid?: false, invalid?: true, message: @message)
        end

        def has_been_used_to_validate?(target)
          @target.equal?(target)
        end
      end
    end
  end
end