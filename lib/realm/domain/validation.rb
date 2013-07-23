module Realm
  module Domain
    module Validation; end
  end
end

require_relative 'validation/command_validator'
require_relative 'validation/email_validator'
require_relative 'validation/regex_validator'