require 'spec_helper'

require 'realm/domain'
require 'realm/spec/matchers'

describe "message matching" do
  let(:message_type) {
    Realm::Messaging::MessageType.new(:test_message_type,
      properties: { foo: String }
    )
  }
  subject(:message) { message_type.new_message(message_type_name: :test_message_type, foo: "bar") }

  describe "#match_message_description" do
    it "matches when it matches" do
      expect(message).to match_message_description(message_type_name: :test_message_type, foo: "bar")
    end

    it "doesn't match when it doesn't match" do
      expect(message).to_not match_message_description(message_type_name: :test_message_type, foo: "baz")
    end
  end

  describe "#match_event_description" do
    it "is an alias" do
      expect(message).to match_event_description(message_type_name: :test_message_type, foo: "bar")
    end
  end

  describe "#match_command_description" do
    it "is an alias" do
      expect(message).to match_command_description(message_type_name: :test_message_type, foo: "bar")
    end
  end
end