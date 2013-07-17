require 'spec_helper'

require 'realm/messaging'
require 'realm/messaging/bus'

module Realm
  module Messaging
    module Bus
      describe UnhandledMessageErrorRaiser do
        let(:message_type) { MessageType.new(:foo, [ :message ]) }
        let(:message_bus) { SimpleMessageBus.new }
        subject(:handler) { UnhandledMessageErrorRaiser.new }

        it "raises an error on unhandled messages" do
          message_bus.register(:unhandled_message, handler)

          expect {
            message_bus.publish(message_type.new_message(uuid: :unused_uuid, message: "bar"))
          }.to raise_error(UnhandledMessageErrorRaiser::UnhandledMessageError) { |error|
            expect(error.message).to include('"foo"')
            expect(error.message).to include("message:")
            expect(error.message).to include("bar")
          }
        end
      end
    end
  end
end
