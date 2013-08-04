require 'spec_helper'

require 'realm/messaging/handlers/message_logger'

module Realm
  module Messaging
    module Handlers
      describe MessageLogger do
        let(:message)   { double("Message", output_to: "formatted_message") }
        let(:formatter) { double("Formatter") }
        let(:logger)    { double("Logger", info: nil) }

        subject(:handler) {
          MessageLogger.new(format_with: formatter, log_to: logger)
        }

        describe "handling messages" do
          it "formats the message" do
            handler.handle_foo(message)
            expect(message).to have_received(:output_to).with(formatter)
          end

          it "logs the formatted message" do
            handler.handle_foo(message)
            expect(logger).to have_received(:info).with("formatted_message")
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