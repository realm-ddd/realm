require 'spec_helper'

require 'realm/domain'
require 'realm/spec/matchers'

module Realm
  module Spec
    describe MessageMatchingArgumentMatcher do
      let(:message_type) {
        Realm::Messaging::MessageType.new(:test_message_type,
          properties: { foo: String }
        )
      }
      subject(:message) { message_type.new_message(message_type_name: :test_message_type, foo: "bar") }

      it "matches when it matches" do
        expect(message_matching(message_type_name: :test_message_type, foo: "bar")).to be == message
      end

      it "doesn't match when it doesn't match" do
        expect(message_matching(message_type_name: :test_message_type, foo: "baz")).to_not be == message
      end

      context "argument is not a matcher" do
        it "doesn't match (as opposed to raising an unexpected error)" do
          expect(message_matching(message_type_name: :test_message_type, foo: "baz")).to_not be == :not_a_message
        end
      end

      describe "aliases" do
        specify "#event_matching" do
          expect(event_matching(message_type_name: :test_message_type, foo: "bar")).to be == message
        end
        specify "#command_matching" do
          expect(command_matching(message_type_name: :test_message_type, foo: "bar")).to be == message
        end
      end
    end
  end
end