require 'spec_helper'

require 'realm/messaging/errors'

module Realm
  module Messaging
    describe NoResponsesFoundError do
      subject(:error) { NoResponsesFoundError.new(:foo) }

      its(:message) { should be == "No responses found for message type :foo" }
    end
  end
end
