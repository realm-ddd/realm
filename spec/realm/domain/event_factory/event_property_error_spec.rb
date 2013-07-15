require 'spec_helper'

require 'realm/domain/event_factory'

module Realm
  module Domain
    class EventFactory
      describe EventFactory::EventPropertyError do
        it "contains the EventType name" do
          expect(
            EventFactory::EventPropertyError.new("test_event_type", [], []).message
          ).to include("EventType(test_event_type)")
        end

        context "given attribute names don't match EventType properties" do
          let(:error) {
            EventFactory::EventPropertyError.new("test_event_type", [:p1, :p2], [:p3, :p4])
          }

          it "includes this in the message" do
            expect(error.message).to include("unknown properties: p3, p4")
          end
        end

        context "an attribute is missing" do
          let(:error) {
            EventFactory::EventPropertyError.new("test_event_type", [:p1, :p2, :p3], [:p1])
          }

          it "includes this in the message" do
            expect(error.message).to include("missing attributes: p2, p3")
          end
        end

        context "both unknown and missing values" do
          let(:error) {
            EventFactory::EventPropertyError.new("test_event_type", [:p3, :p2, :p1], [:p5, :p4, :p2])
          }

          it "sorts everything" do
            expect(
              error.message
            ).to be == "Attributes did not match EventType(test_event_type) properties - unknown properties: p4, p5; missing attributes: p1, p3"
          end
        end
      end
    end
  end
end