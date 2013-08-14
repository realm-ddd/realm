require 'spec_helper'

module Realm
  module Messaging
    describe UnhandledMessageError do
      context "with a domain message" do
        let(:messages) {
          MessageFactory.new do |messages|
            messages.define(:test_message,
              properties: { test_property: String }
            )
          end
        }

        let(:message) { messages.build(:test_message, test_property: "foo") }

        subject(:error) { UnhandledMessageError.new(message) }

        its(:message) { should match(/Unhandled message:.*test_message.*test_property.*foo/) }

        its(:domain_message) { should be(message) }
        its(:domain_message) { should be_a(Message) }

        its(:message_type) { should be == :test_message }
      end

      # This is a hack to let us re-use UnhandledMessageError for symbols, argubly if
      # we don't create a new error type for this, we should at least store the whole
      # message (see MessageResponse classes), as then it'd be at least semantically
      # equivalent to the information in a Message
      context "with a primitive message (ie a symbol for a message name)" do
        let(:message) { :some_message_name }

        subject(:error) { UnhandledMessageError.new(message) }

        its(:message) { should match(/Unhandled message:.*:some_message_name/) }

        # Because we know we need some sort of decorator to get the right behaviour...
        its(:domain_message) { should_not be(message) }

        specify {
          expect(error.domain_message.to_s).to be == ":some_message_name"
        }

        its(:message_type) { should be == :some_message_name }
      end

      context "with anything else (you're on your own)" do
        let(:message) {
          double("Message",
            message_type: :stubbed_message_type, to_s: "message#to_s"
          )
        }

        subject(:error) { UnhandledMessageError.new(message) }

        its(:message) { should match(/Unhandled message:.*message#to_s/) }

        its(:domain_message) { should be(message) }

        specify {
          expect(error.domain_message.to_s).to be == "message#to_s"
        }
        its(:message_type) { should be == :stubbed_message_type }
      end
    end
  end
end