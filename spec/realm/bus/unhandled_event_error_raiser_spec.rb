require 'spec_helper'

require 'realm/bus'

module Realm
  module Bus
    describe UnhandledEventErrorRaiser do
      let(:event_type) { Domain::EventFactory::EventType.new(:foo, [ :message ]) }
      let(:event_bus) { SimpleEventBus.new }
      subject(:handler) { UnhandledEventErrorRaiser.new }

      it "raises an error on unhandled events" do
        event_bus.register(:unhandled_event, handler)

        expect {
          event_bus.publish(event_type.new_event(uuid: :unused_uuid, message: "bar"))
        }.to raise_error(UnhandledEventErrorRaiser::UnhandledEventError) { |error|
          expect(error.message).to include('"foo"')
          expect(error.message).to include("message:")
          expect(error.message).to include("bar")
        }
      end
    end
  end
end
