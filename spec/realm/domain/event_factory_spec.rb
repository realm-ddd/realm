require 'spec_helper'

require 'realm/domain/event_factory'

module Realm
  module Domain
    describe EventFactory do
      let(:event_type) { double(EventFactory::EventType) }
      let(:event_type_factory) { double("EventTypeFactory", new: event_type) } # Unnamed type
      subject(:event_factory) { EventFactory.new(event_type_factory) }

      describe "#define" do
        it "builds the EventType" do
          event_type_factory.should_receive(:new).with(:event_type_name, [:property_1, :property_2])
          event_factory.define(:event_type_name, :property_1, :property_2)
        end
      end

      describe "#build" do
        context "EventType is defined" do
          before(:each) do
            event_factory.define(:event_type_name, :property_1, :property_2)
          end

          it "tells the EventType to build an event" do
            event_type.should_receive(:new_event).with(
              property_1: "attribute 1", property_2: "attribute 2"
            )
            event_factory.build(
              :event_type_name, property_1: "attribute 1", property_2: "attribute 2"
            )
          end
        end

        context "EventType is not defined" do
          it "raises an error" do
            expect {
              event_factory.build(:unknown_event_type_name)
            }.to raise_error(EventFactory::UnknownEventType) { |error|
              expect(error.message).to include("unknown_event_type_name")
            }
          end
        end
      end
    end
  end
end
