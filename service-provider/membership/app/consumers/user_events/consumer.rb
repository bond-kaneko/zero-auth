# frozen_string_literal: true

module UserEvents
  # Karafka consumer adapter that bridges Kafka messages to the abstracted EventConsumer
  # This keeps Kafka-specific code isolated and makes the system testable
  class Consumer < Karafka::BaseConsumer
    def consume
      messages.each do |message|
        process_message(message)
      end
    end

    private

    def process_message(message)
      # Karafka deserializes JSON automatically, so payload is already a Hash
      event = message.payload.is_a?(String) ? JSON.parse(message.payload) : message.payload
      event_type = event["event_type"]
      event_id = event["event_id"]

      Rails.logger.info("Received event: #{event_type} - #{event_id}")

      # Delegate to the abstracted EventConsumer
      Events::EventConsumer.current.consume(
        event_type: event_type,
        payload: event["payload"],
      )
    rescue JSON::ParserError => e
      Rails.logger.error("Failed to parse message: #{e.message}")
    rescue Events::EventConsumer::ConsumeError => e
      Rails.logger.error("Failed to consume event: #{e.message}")
    rescue StandardError => e
      Rails.logger.error("Unexpected error processing event: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
    end
  end
end
