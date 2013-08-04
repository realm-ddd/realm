require 'spec_helper'

require 'realm/messaging/handlers/message_logger'

module Realm
  module Messaging
    module Handlers
      describe MessageLogger do
        let(:message) { double("message", to_s: "message as string") }
        let(:logger) { double("Logger", info: nil) }

        subject(:handler) { MessageLogger.new(logger) }

        describe "handling messages" do
          example "handle_foo" do
            handler.handle_foo(message)
            expect(logger).to have_received(:info).with("message as string")
          end

          specify "only handle_* messages are caught" do
            expect {
              handler.bar_foo
            }.to raise_error(NoMethodError)
          end

          specify "only one argument is accepted" do
            expect {
              handler.handle_foo(message, :superfluous_argument)
            }.to raise_error(ArgumentError) { |error|
              expect(error.message).to be == "wrong number of arguments (2 for 1)"
            }
          end

          # The current implelementation of SimpleMessageBus#send mitigates this:

          # # Workaround for our arguable quirky way of using MessageBus#send with a response
          # # port to handle command messages
          # specify "a response_port argument is ignored" do
          #   pending
          # end
        end
      end
    end
  end
end