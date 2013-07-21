require 'spec_helper'

require 'realm/domain'
require 'realm/spec'

module Realm
  module Spec
    describe MessageMatchingArgumentMatcher do
      let(:message_type) {
        Realm::Messaging::MessageType.new(:test_message_type, [ :foo ])
      }
      subject(:message) { message_type.new_message(message_type: :test_message_type, foo: "bar") }

      it "matches when it matches" do
        expect(message_matching(message_type: :test_message_type, foo: "bar")).to be == message
      end

      it "doesn't match when it doesn't match" do
        expect(message_matching(message_type: :test_message_type, foo: "baz")).to_not be == message
      end

      describe "aliases" do
        specify "#event_matching" do
          expect(event_matching(message_type: :test_message_type, foo: "bar")).to be == message
        end
        specify "#command_matching" do
          expect(command_matching(message_type: :test_message_type, foo: "bar")).to be == message
        end
      end
    end
  end
end