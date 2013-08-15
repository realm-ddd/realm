require 'spec_helper'

require 'realm/messaging/result_factory'

module Realm
  module Messaging
    describe ResultFactory do
      let(:do_this_message) { double(Message, message_type: :do_this) }
      let(:do_something_else_message) { double(Message, message_type: :do_something_else) }

      let(:commands) {
        MessageFactory.new do |commands|
          commands.define(:do_this,
            responses: [ :this_happened, :that_happened ]
          )
          commands.define(:do_something_else,
            responses: [ :the_other_happened ]
          )
        end
      }

      let(:responses) {
        MessageFactory.new do |responses|
          responses.define(:this_happened)
          responses.define(:that_happened)
          responses.define(:_unused_outcome_)
        end
      }

      subject(:factory) {
        ResultFactory.new(commands: commands, responses: responses)
      }

      describe "#new_unresolved_result" do
        let(:result) { factory.new_unresolved_result(do_this_message) }

        context "response MessageType(s) exists " do
          it "constructs a result with the responses" do
            expect(result.understand_response?(:this_happened)).to be_true
            expect(result.understand_response?(:that_happened)).to be_true
          end

          it "ignores other responses" do
            expect(result.understand_response?(:the_other_happened)).to be_false
          end

          it "creates a result" do
            expect(factory.new_unresolved_result(do_this_message)).to be_a(Result)
          end
        end

        context "a response message type can't be found" do
          it "raises an error (we'd be constructing an unresolvable Result)" do
            expect {
              factory.new_unresolved_result(do_something_else_message)
            }.to raise_error(NoResponsesFoundError, /do_something_else/)
          end
        end
      end
    end
  end
end
