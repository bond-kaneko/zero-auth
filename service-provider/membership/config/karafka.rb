# frozen_string_literal: true

class KarafkaApp < Karafka::App
  setup do |config|
    config.kafka = {
      'bootstrap.servers': ENV.fetch("KAFKA_BROKERS", "kafka:9092"),
      'client.id': "membership-service"
    }

    config.client_id = "membership-service"
  end

  routes.draw do
    consumer_group "membership-user-sync" do
      topic "user-events" do
        consumer UserEvents::Consumer
      end
    end
  end
end
