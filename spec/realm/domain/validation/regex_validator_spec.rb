require 'spec_helper'

require 'realm/domain/validation/regex_validator'

module Realm
  module Domain
    module Validation
      describe RegexValidator do
        let(:validator) { RegexValidator.new(/^\w+$/) }

        context "valid" do
          subject(:result) { validator.validate("valid") }

          its(:valid?) { should be_true }
        end

        context "invalid" do
          subject(:result) { validator.validate("this is invalid!") }

          its(:valid?) { should be_false }
        end
      end
    end
  end
end
