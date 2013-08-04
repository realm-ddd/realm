module Realm
  module Messaging
    module Handlers
      class MessageLogger
        def initialize(format_with: r(:format_with), log_to: r(:log_to))
          @formatter  = format_with
          @logger     = log_to
        end

        def method_missing(name, *args, &block)
          if name =~ /^handle_/
            raise_if_arg_length_is_incorrect(expected_length: 1, actual_length: args.length)
            log_message(args.first)
          else
            super
          end
        end

        private

        def log_message(message)
          @logger.info(
            format_message(message)
          )
        end

        def format_message(message)
          message.output_to(@formatter)
        end

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