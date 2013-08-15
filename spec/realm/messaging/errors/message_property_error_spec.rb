require 'spec_helper'

require 'realm/messaging/errors'

module Realm
  module Messaging
    describe MessagePropertyError do
      it "contains the MessageType name" do
        expect(
          MessagePropertyError.new("test_message_type", [], []).message
        ).to include("MessageType(test_message_type)")
      end

      context "given attribute names don't match MessageType properties" do
        let(:error) {
          MessagePropertyError.new("test_message_type", [:p1, :p2], [:p3, :p4])
        }

        it "includes this in the message" do
          expect(error.message).to include("unknown properties: p3, p4")
        end
      end

      context "an attribute is missing" do
        let(:error) {
          MessagePropertyError.new("test_message_type", [:p1, :p2, :p3], [:p1])
        }

        it "includes this in the message" do
          expect(error.message).to include("missing attributes: p2, p3")
        end
      end

      context "both unknown and missing values" do
        let(:error) {
          MessagePropertyError.new("test_message_type", [:p3, :p2, :p1], [:p5, :p4, :p2])
        }

        it "sorts everything" do
          expect(
            error.message
          ).to be == "Attributes did not match MessageType(test_message_type) properties - unknown properties: p4, p5; missing attributes: p1, p3"
        end
      end
    end
  end
end