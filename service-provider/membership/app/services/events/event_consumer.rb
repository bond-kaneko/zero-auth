# frozen_string_literal: true

module Events
  # Abstract interface for event consumers
  # Allows switching between different messaging systems (Kafka, SQS, Pub/Sub, etc.)
  class EventConsumer
    class ConsumeError < StandardError; end

    class << self
      def current
        @current ||= begin
          consumer_type = ENV.fetch("EVENT_CONSUMER_TYPE", "karafka")
          case consumer_type
          when "karafka"
            Events::KarafkaEventConsumer.new
          else
            raise ArgumentError, "Unknown event consumer type: #{consumer_type}"
          end
        end
      end

      def current=(consumer)
        @current = consumer
      end
    end

    # Process a single event
    # @param event_type [String] The type of event (e.g., 'user.created')
    # @param payload [Hash] The event payload
    # @return [void]
    def consume(event_type:, payload:)
      raise NotImplementedError, "#{self.class}#consume must be implemented"
    end
  end
end
