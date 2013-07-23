require 'spec_helper'

require 'realm/domain/validation/email_validator'

module Realm
  module Domain
    module Validation
      describe EmailValidator do
        let(:validator) { EmailValidator.new }

        context "email@example.com" do
          subject(:result)  { validator.validate("email@example.com") }
          its(:valid?)      { should be_true }
        end

        context "Email.address_123@something.Example.com" do
          subject(:result)  { validator.validate("Email.address_123@something.Example.com") }
          its(:valid?)      { should be_true }
        end

        context "email" do
          subject(:result)  { validator.validate("email") }
          its(:valid?)      { should be_false }
        end

        context "email@" do
          subject(:result)  { validator.validate("email@") }
          its(:valid?)      { should be_false }
        end

        context "email@example" do
          subject(:result)  { validator.validate("email@example") }
          its(:valid?)      { should be_false }
        end

        context "email @example" do
          subject(:result)  { validator.validate("email @example") }
          its(:valid?)      { should be_false }
        end

        context "email@example." do
          subject(:result)  { validator.validate("email@example.") }
          its(:valid?)      { should be_false }
        end

        context "completely invalid input" do
          subject(:result)  { validator.validate("completely invalid input") }
          its(:valid?)      { should be_false }
        end

      end
    end
  end
end
