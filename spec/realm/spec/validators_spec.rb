require 'spec_helper'

require 'realm/spec/validators'

module Realm
  module Domain
    module Validation
      describe AlwaysValidValidator do
        let(:target) { "target_object" }
        subject(:validator) { AlwaysValidValidator.new }

        describe "result" do
          subject(:result) { validator.validate(target) }

          its(:valid?)    { should be_true }
          its(:invalid?)  { should be_false }
          its(:message)   { should be_nil }
        end

        describe "#has_been_used_to_validate?" do
          specify {
            validator.validate(target)
            expect(validator).to have_been_used_to_validate(target)
          }

          specify {
            validator.validate(target)
            expect(validator).to_not have_been_used_to_validate("target_object")
          }
        end
      end

      describe AlwaysInvalidValidator do

        let(:target) { "target_object" }
        subject(:validator) { AlwaysInvalidValidator.new(message: "validation message") }

        describe "result" do
          subject(:result) { validator.validate(target) }

          its(:valid?)    { should be_false }
          its(:invalid?)  { should be_true }
          its(:message)   { should be == "validation message" }
        end

        describe "#has_been_used_to_validate?" do
          specify {
            validator.validate(target)
            expect(validator).to have_been_used_to_validate(target)
          }

          specify {
            validator.validate(target)
            expect(validator).to_not have_been_used_to_validate("target_object")
          }
        end
      end
    end
  end
end