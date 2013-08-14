require 'timeout'
require 'ap'

require 'realm'
require 'realm/spec'
require 'realm/spec/matchers'

RSpec.configure do |config|
  config.filter_run(focus: true)
  config.run_all_when_everything_filtered = true

  # We've already defined `speed: :slow` but don't have a filter system for them yet

  config.expect_with :rspec do |c|
    # Disable the `should` syntax
    c.syntax = :expect
  end

  config.around(:each, async: true) do |example|
    Timeout::timeout(1) do
      example.run
    end
  end
end
