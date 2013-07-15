class UnhandledEventErrorRaiser
  class UnhandledEventError < RuntimeError; end

  def handle_unhandled_event(event)
    raise UnhandledEventError.new("Unhandled event: " + event.to_s)
  end
end