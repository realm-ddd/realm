require 'spec_helper'

require 'realm/messaging/errors'

module Realm
  module Messaging
    describe UnknownMessageTypeError do
      subject(:error) { UnknownMessageTypeError.new(:foo) }

      its(:message) { should be == "Unknown message type :foo" }
    end
  end
end