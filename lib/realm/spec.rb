require_relative 'spec/domain'
require_relative 'spec/messaging'

# Specifically not auto-required as these depend on RSpec and we can't assume
# every Realm user will be using RSpec:
# require_relative 'spec/matchers'
