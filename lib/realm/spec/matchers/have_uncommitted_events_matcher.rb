RSpec::Matchers.define :have_uncommitted_events do |*expected_events|
  match do |aggregate_root|
    expected_events.all? { |expected_event|
      aggregate_root.uncommitted_events.detect { |event|
        event.matches?(expected_event)
      }
    }
  end
end

RSpec::Matchers.define :have_no_uncommitted_events do
  match do |aggregate_root|
    aggregate_root.uncommitted_events.empty?
  end

  failure_message_for_should do |aggregate_root|
    "Expected #{aggregate_root} to have no uncommitted_events but it had: \n" +
    aggregate_root.uncommitted_events.map { |event| "*  #{event}\n" }.join
  end
end