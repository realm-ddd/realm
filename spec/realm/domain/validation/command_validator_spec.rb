require 'spec_helper'
require 'ostruct'

require 'realm/domain/validation'

module Realm
  module Domain
    module Validation
      describe CommandValidator, "empty" do
        let(:command) { :this_is_not_a_command }
        let(:validator) { CommandValidator.new }

        subject(:result) { validator.validate(command) }

        # Currently, at least...
        its(:valid?) { should be_true }
        its(:message) { should be_nil }
      end

      describe CommandValidator do
        let(:command) { ClassName.new }

        let(:foo_validator) { RegexValidator.new(/^[a-z]+$/) }
        let(:bar_validator) { RegexValidator.new(/^[0-9]+$/) }
        let(:validator) {
          CommandValidator.new(
            validators: { foo: foo_validator, bar: bar_validator },
            messages: {
              foo: "Foo must be alphabetic",
              bar: "Bar must be only digits"
            }
          )
        }

        subject(:result) { validator.validate(command) }

        describe "#validate" do
          context "no violations" do
            let(:command) { OpenStruct.new(foo: "abc", bar: "123") }

            its(:valid?) { should be_true }
            its(:message) { should be_nil }
          end

          context "a violation" do
            let(:command) { OpenStruct.new(foo: "abc", bar: "not digits") }

            its(:valid?) { should be_false }
            its(:message) { should be == "Bar must be only digits" }
          end

          context "multiple violations" do
            let(:command) { OpenStruct.new(foo: "123!", bar: "not digits") }

            its(:valid?) { should be_false }
            its(:message) { should be == "Foo must be alphabetic; Bar must be only digits" }
          end
        end
      end
    end
  end
end
