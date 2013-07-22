require 'spec_helper'

require 'realm/domain/validation/regex_validator'

module Realm
  module Domain
    module Validation
      describe RegexValidator do
        let(:prototype) { RegexValidator.new(/\d/, name: :number_regex) }

        let(:listener) { double("Validation Listener", attribute_failed_validation: nil) }
        subject(:validator) { prototype.dup_for_listener(listener) }

        describe "#attribute_declared" do
          example "matching" do
            validator.attribute_declared(:foo, "foo123bar")
            expect(listener).to_not have_received(:attribute_failed_validation)
          end

          example "not matching" do
            validator.attribute_declared(:foo, "foo___bar")
            expect(listener).to have_received(:attribute_failed_validation).with(:foo, :number_regex)
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
