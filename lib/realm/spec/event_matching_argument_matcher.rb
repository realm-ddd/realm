module Realm
  module Spec
    class EventMatchingArgumentMatcher
      def initialize(event_description)
        @event_description = event_description
      end

      def ==(event)
        event.matches?(@event_description)
      end
    end

    def event_matching(event_description)
      EventMatchingArgumentMatcher.new(event_description)
    end
  end
end

RSpec.configure do |config|
  config.include(Realm::Spec)
end