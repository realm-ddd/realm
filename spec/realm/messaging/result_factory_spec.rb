require 'spec_helper'

require 'realm/messaging/result_factory'

module Realm
  module Messaging
    describe ResultFactory do
      let(:message) { :todo }
      subject(:factory) { ResultFactory.new }

      describe "#new_unresolved_result" do
        # Currently all we do is create a blank result, so we don't actually
        # need to pass the message. But I'm leaving this here to nag me, as
        # I want to the message-response protocols explicitly
        it "should creates a result" do
          expect(factory.new_unresolved_result(message)).to be_a(Result)
        end
      end
    end
  end
end
