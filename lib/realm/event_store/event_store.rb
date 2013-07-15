# Just a placeholder at the moment to give us the constant name
module Realm
  module EventStore
    class UnknownAggregateRootError < RuntimeError
      def initialize(uuid)
        @uuid = uuid
      end

      def message
        "Unknown AggregateRoot: #{@uuid.inspect}"
      end
    end

    module EventStore

    end
  end
end