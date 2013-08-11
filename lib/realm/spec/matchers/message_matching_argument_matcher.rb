module Realm
  module Spec
    class MessageMatchingArgumentMatcher
      def initialize(message_description)
        @message_description = message_description
      end

      def ==(message)
        message.matches?(@message_description)
      end
    end

    def message_matching(message_description)
      MessageMatchingArgumentMatcher.new(message_description)
    end

    alias_method :event_matching,   :message_matching
    alias_method :command_matching, :message_matching
  end
end

RSpec.configure do |config|
  config.include(Realm::Spec)
end