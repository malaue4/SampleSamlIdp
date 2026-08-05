class SendEventsToStdout
  def emit(event)
    puts event.inspect
  end
end

# Rails.event.subscribe(SendEventsToStdout.new)
