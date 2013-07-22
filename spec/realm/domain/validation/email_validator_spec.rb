require 'spec_helper'

require 'realm/domain/validation/email_validator'

module Realm
  module Domain
    module Validation
      describe EmailValidator do
        let(:prototype) { EmailValidator.new(name: :email_address) }

        let(:listener) { double("Validation Listener", attribute_failed_validation: nil) }
        subject(:validator) { prototype.dup_for_listener(listener) }

        describe "#attribute_declared" do
          example "email@example.com" do
            validator.attribute_declared(:foo, "email@example.com")
            expect(listener).to_not have_received(:attribute_failed_validation)
          end

          example "Email.address_123@something.Example.com" do
            validator.attribute_declared(:foo, "Email.address_123@something.Example.com")
            expect(listener).to_not have_received(:attribute_failed_validation)
          end

          example "email" do
            validator.attribute_declared(:foo, "email")
            expect(listener).to have_received(:attribute_failed_validation).with(:foo, :email_address)
          end

          example "email@" do
            validator.attribute_declared(:foo, "email@")
            expect(listener).to have_received(:attribute_failed_validation).with(:foo, :email_address)
          end

          example "email@example" do
            validator.attribute_declared(:foo, "email@example")
            expect(listener).to have_received(:attribute_failed_validation).with(:foo, :email_address)
          end

          example "email @example" do
            validator.attribute_declared(:foo, "email @example")
            expect(listener).to have_received(:attribute_failed_validation).with(:foo, :email_address)
          end

          example "email@example." do
            validator.attribute_declared(:foo, "email@example.")
            expect(listener).to have_received(:attribute_failed_validation).with(:foo, :email_address)
          end

          # This is normal Ruby behaviour, but as I toyed with the idea of
          # using #to_str string coercion, I left this in to be explicit
          example "completely invalid input" do
            expect {
              validator.attribute_declared(:foo, Object.new)
            }.to raise_error(TypeError)
          end
        end
      end
    end
  end
end
