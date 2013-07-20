require 'spec_helper'

module Realm
  module Messaging
    describe UnhandledMessageError do

      let(:messages) {
        MessageFactory.new do |messages|
          messages.define(:test_message, :test_property)
        end
      }

      let(:message) { messages.build(:test_message, uuid: nil, test_property: "foo") }

      subject(:error) { UnhandledMessageError.new(message) }

      its(:message) { should match(/Unhandled message:.*test_message.*test_property.*foo/) }
      its(:domain_message) { should be(message) }
      its(:domain_message) { should be_a(Message) }
    end
  end
end