module Realm
  module Domain
    module Validation; end
  end
end

require_relative 'validation/entity_validator'
require_relative 'validation/email_validator'
require_relative 'validation/regex_validator'