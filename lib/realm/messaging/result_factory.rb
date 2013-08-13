require_relative 'result'

module Realm
  module Messaging
    class ResultFactory
      def new_unresolved_result(message)
        Result.new
      end
    end
  end
end
