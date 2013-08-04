module Realm
  module Messaging
    module Handlers
      class MessageLogger
        def initialize(logger)
          @logger = logger
        end

        def method_missing(name, *args, &block)
          if name =~ /^handle_/
            raise_if_arg_length_is_incorrect(expected_length: 1, actual_length: args.length)

            message = args.first
            @logger.info(message.to_s)
          else
            super
          end
        end

        private

        def raise_if_arg_length_is_incorrect(
          expected_length: r(:expected_length), actual_length: r(:actual_length)
        )
          if actual_length != expected_length
            raise ArgumentError.new("wrong number of arguments (#{actual_length} for #{expected_length})")
          end
        end
      end
    end
  end
end