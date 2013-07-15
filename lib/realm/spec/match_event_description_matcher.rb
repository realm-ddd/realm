RSpec::Matchers.define :match_event_description do |event_description|
  match do |actual_event|
    actual_event.matches?(event_description)
  end
end
