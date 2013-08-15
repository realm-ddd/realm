require_relative 'result'

module Realm
  module Messaging
    class ResultFactory
      # Pass in MessageFactory objects for the commands and response messages -
      # these could be the same object if that is convenient for the client
      def initialize(commands: required(:commands), responses: required(:responses))
        @commands   = commands
        @responses  = responses
      end

      def new_unresolved_result(message)
        Result.new(responses: response_for(message.message_type_name))
      end

      private

      def response_for(message_type_name)
        @commands.determine_responses_to(message_type_name, from: @responses).tap do |responses|
          raise NoResponsesFoundError.new(message_type_name) if responses.none?
        end
      end
    end
  end
end
