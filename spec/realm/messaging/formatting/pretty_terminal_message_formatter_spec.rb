require 'spec_helper'

require 'term/ansicolor'

require 'realm/messaging/formatting/pretty_terminal_message_formatter'

module Realm
  module Messaging
    module Formatting
      describe PrettyTerminalMessageFormatter do
        include Term::ANSIColor

        let(:message_attributes) {
          {
            category:   :message,
            type:       :test_message_type,
            version:    1,
            timestamp:  :test_timestamp,
            attributes: {
              uuid:       :test_uuid,
              property_1: "attribute 1",
              property_2: nil
            }
          }
        }

        let(:formatter) { PrettyTerminalMessageFormatter.new }

        let(:colored_output) { formatter.format(message_attributes) }
        subject(:uncolored_output) { uncolor(colored_output) }

        it { should include("message") }
        it { should include("type=test_message_type") }
        it { should include("version=1") }
        it { should include("timestamp=:test_timestamp") }
        it { should include("property_1:") }
        it { should include("attribute 1") }
        it { should include("property_2:") }
        it { should include("nil") }

        # Change `if false` to `if true` to visually inspect the output,
        # then change back again before committing
        it "looks pretty" do
          if false
            puts colored_output
            raise "this example should be disabled when it the output looks pretty"
          end
        end
      end
    end
  end
end