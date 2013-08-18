require 'spec_helper'

require 'realm/messaging'

module Realm
  module Messaging
    module Bus
      describe UnhandledMessageSentinel do
        let(:message_type)  {
          MessageType.new(:foo, properties: { message: String })
        }
        let(:message)       { message_type.new_message(message: "bar") }
        subject(:handler)   { UnhandledMessageSentinel.new }

        it "raises an error on unhandled messages" do
          expect {
            handler.handle_unhandled_message(message)
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
