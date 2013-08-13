require 'spec_helper'

require 'realm/messaging'

module Realm
  module Messaging
    module Bus
      describe UnhandledMessageSentinel do
        # We need this dependency for the bus even though it's only used
        # for #send - either we need to change the design or provide a way
        # to construct this without an explicit unused dependency here
        let(:result_factory) { :_unused_ }

        let(:event_bus) { Messaging::Bus::SimpleMessageBus.new(result_factory: result_factory) }

        let(:message_type)  { MessageType.new(:foo, [ :message ]) }
        let(:message)       { message_type.new_message(message: "bar") }
        let(:message_bus)   { SimpleMessageBus.new(result_factory: result_factory) }
        subject(:handler)   { UnhandledMessageSentinel.new }

        it "raises an error on unhandled messages" do
          message_bus.register(:unhandled_message, handler)

          expect {
            message_bus.publish(message)
          }.to raise_error(UnhandledMessageError) { |error|
            expect(error.message).to include('"foo"')
            expect(error.message).to include("message:")
            expect(error.message).to include("bar")
            expect(error.domain_message).to be(message)
          }
        end
      end
    end
  end
end
