require 'spec_helper'

require 'realm/domain'
require 'realm/spec'

describe "message matching" do
  let(:message_type) {
    Realm::Messaging::MessageType.new(:test_message_type, [ :foo ])
  }
  subject(:message) { message_type.new_message(message_type: :test_message_type, uuid: :test_uuid, foo: "bar") }

  describe "#match_message_description" do
    it "matches when it matches" do
      expect(message).to match_message_description(message_type: :test_message_type, uuid: :test_uuid, foo: "bar")
    end

    it "doesn't match when it doesn't match" do
      expect(message).to_not match_message_description(message_type: :test_message_type, uuid: :test_uuid, foo: "baz")
    end
  end

  describe "#match_event_description" do
    it "is an alias" do
      expect(message).to match_event_description(message_type: :test_message_type, uuid: :test_uuid, foo: "bar")
    end
  end
end