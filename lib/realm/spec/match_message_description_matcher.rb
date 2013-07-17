RSpec::Matchers.define :match_message_description do |message_description|
  match do |actual_message|
    actual_message.matches?(message_description)
  end
end

RSpec::Matchers.define :match_event_description do |message_description|
  match do |actual_message|
    actual_message.matches?(message_description)
  end
end
