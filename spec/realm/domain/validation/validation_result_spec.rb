require 'realm/domain/validation/validation_result'

module Realm
  module Domain
    module Validation
      describe ValidationResult do
        subject(:result) { ValidationResult.new }

        context "initially" do
          its(:valid?)    { should be_true }
          its(:invalid?)  { should be_false }
          its(:message)   { should be_nil }
        end

        context "marked invalid" do
          before(:each) do
            result.invalid
          end

          its(:valid?)    { should be_false }
          its(:invalid?)  { should be_true }
          its(:message)   { should be_nil }

          context "with a message" do
            before(:each) do
              result.add_message("foo")
            end

            its(:message) { should be == "foo" }
          end

          context "with multple messages" do
            before(:each) do
              result.add_message("foo")
              result.add_message("bar")
              result.add_message("baz")
            end

            its(:message) { should be == "foo; bar; baz" }
          end

          context "then valid again" do
            before(:each) do
              result.valid
            end

            its(:valid?)    { should be_true }
            its(:invalid?)  { should be_false }
            its(:message)   { should be_nil }

            context "with a message" do
              before(:each) do
                result.add_message("foo")
              end

              its(:message) { should be_nil }
            end
          end
        end
      end
    end
  end
end
