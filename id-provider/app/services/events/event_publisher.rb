# frozen_string_literal: true

module Events
  # Base class for event publishers
  # Provides interface for publishing domain events to message brokers
  class EventPublisher
    class PublishError < StandardError; end

    # Get current event publisher instance based on environment
    # @return [EventPublisher] Publisher instance for current environment
    def self.current
      @current ||= case Rails.env
                   when 'production'
                     raise NotImplementedError, 'Production event publisher not yet implemented'
                   else
                     KarafkaEventPublisher.new
                   end
    end

    # Reset current publisher (mainly for testing)
    def self.reset!
      @current = nil
    end

    # Publish an event to the message broker
    # @param event_type [String] Type of the event (e.g., 'user.created', 'user.deleted')
    # @param payload [Hash] Event payload data
    # @raise [PublishError] if publish fails
    def publish(event_type:, payload:)
      raise NotImplementedError, "#{self.class} must implement #publish"
    end

    # Format event payload with metadata
    # @param event_type [String] Type of the event
    # @param payload [Hash] Event data
    # @return [Hash] Formatted event with metadata
    def format_event(event_type:, payload:)
      {
        event_type: event_type,
        event_id: SecureRandom.uuid,
        timestamp: Time.current.iso8601,
        version: '1.0',
        payload: payload,
      }
    end
  end
end
