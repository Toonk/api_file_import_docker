# frozen_string_literal: true

module FireEvent
  extend ActiveSupport::Concern

  def fire_event(event_name, bang: false)
    unless respond_to?("may_#{event_name}?")
      raise "Invalid event name: #{event_name} for #{self.class}"
    end

    send("#{event_name}#{bang ? '!' : ''}")
  end

  def fire_event!(event_name)
    fire_event(event_name, bang: true)
  end
end
