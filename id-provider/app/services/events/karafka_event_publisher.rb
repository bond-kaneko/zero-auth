# frozen_string_literal: true

module Events
  # Event publisher using Karafka/Kafka for event streaming
  class KarafkaEventPublisher < EventPublisher
    def initialize(producer: WaterDrop::Producer.new)
      super()
      @producer = producer
      configure_producer
    end

    # Publish event to Kafka topic
    # @param event_type [String] Type of the event (e.g., 'user.created')
    # @param payload [Hash] Event payload data
    def publish(event_type:, payload:)
      event = format_event(event_type: event_type, payload: payload)
      topic = kafka_topic_for(event_type)

      @producer.produce_async(
        topic: topic,
        payload: event.to_json,
        headers: {
          'event_type' => event_type,
          'event_id' => event[:event_id],
        },
      )

      Rails.logger.info("Published event to Kafka: #{event_type} to topic #{topic}")
    rescue WaterDrop::Errors::ProduceError => e
      Rails.logger.error("Failed to publish event to Kafka: #{event_type} - #{e.message}")
      raise PublishError, "Failed to publish event: #{e.message}"
    end

    private

    def configure_producer
      @producer.setup do |config|
        config.kafka = {
          'bootstrap.servers': ENV.fetch('KAFKA_BROKERS', 'kafka:9092'),
          'client.id': 'id-provider',
        }
      end
    end

    def kafka_topic_for(event_type)
      # Convert event_type to topic name (e.g., 'user.created' -> 'user-events')
      domain = event_type.split('.').first
      "#{domain}-events"
    end
  end
end
