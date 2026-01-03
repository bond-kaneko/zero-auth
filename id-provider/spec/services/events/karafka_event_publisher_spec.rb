# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Events::KarafkaEventPublisher do
  let(:mock_producer) { instance_double(WaterDrop::Producer) }
  let(:mock_config) { double('config') } # rubocop:disable RSpec/VerifiedDoubles
  let(:publisher) { described_class.new(producer: mock_producer) }

  before do
    allow(mock_config).to receive(:kafka=)
    allow(mock_producer).to receive(:setup).and_yield(mock_config)
  end

  describe '#publish' do
    let(:event_type) { 'user.created' }
    let(:payload) do
      {
        user_id: 'test-user-123',
        email: 'test@example.com',
        name: 'Test User',
      }
    end

    it 'publishes event to Kafka topic' do
      published_args = nil
      allow(mock_producer).to receive(:produce_async) { |args| published_args = args }

      publisher.publish(event_type: event_type, payload: payload)

      expect(published_args).to match(
        topic: 'user-events',
        payload: a_string_matching(/#{event_type}/),
        headers: hash_including('event_type' => event_type, 'event_id' => a_kind_of(String)),
      ).and(satisfy do |args|
        event = JSON.parse(args[:payload])
        event['event_type'] == event_type && event['payload'] == payload.stringify_keys &&
          event['event_id'].present? && event['timestamp'].present? && event['version'] == '1.0'
      end)
    end

    it 'logs successful publish' do
      allow(mock_producer).to receive(:produce_async)
      allow(Rails.logger).to receive(:info)

      publisher.publish(event_type: event_type, payload: payload)

      expect(Rails.logger).to have_received(:info).with(
        /Published event to Kafka: #{event_type} to topic user-events/,
      )
    end

    context 'when publish fails' do
      before do
        allow(mock_producer).to receive(:produce_async).and_raise(
          WaterDrop::Errors::ProduceError.new('Connection failed'),
        )
      end

      it 'logs error' do
        allow(Rails.logger).to receive(:error)

        expect do
          publisher.publish(event_type: event_type, payload: payload)
        end.to raise_error(Events::EventPublisher::PublishError, /Failed to publish event/)

        expect(Rails.logger).to have_received(:error).with(
          /Failed to publish event to Kafka: #{event_type}/,
        )
      end

      it 'raises PublishError' do
        allow(Rails.logger).to receive(:error)

        expect do
          publisher.publish(event_type: event_type, payload: payload)
        end.to raise_error(Events::EventPublisher::PublishError)
      end
    end
  end

  describe 'topic naming' do
    it 'converts user.created to user-events topic' do
      allow(mock_producer).to receive(:produce_async)

      publisher.publish(event_type: 'user.created', payload: { user_id: '123' })

      expect(mock_producer).to have_received(:produce_async) do |args|
        expect(args[:topic]).to eq('user-events')
      end
    end

    it 'converts user.deleted to user-events topic' do
      allow(mock_producer).to receive(:produce_async)

      publisher.publish(event_type: 'user.deleted', payload: { user_id: '123' })

      expect(mock_producer).to have_received(:produce_async) do |args|
        expect(args[:topic]).to eq('user-events')
      end
    end
  end
end
