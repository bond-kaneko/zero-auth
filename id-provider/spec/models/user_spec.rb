# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  let(:mock_publisher) { instance_double(Events::KarafkaEventPublisher) }

  before do
    allow(Events::EventPublisher).to receive(:current).and_return(mock_publisher)
  end

  describe 'event publishing' do
    describe 'on create' do
      it 'publishes user.created event after commit' do
        allow(mock_publisher).to receive(:publish)

        described_class.create!(
          email: 'newuser@example.com',
          name: 'New User',
          password: 'password123',
          password_confirmation: 'password123',
        )

        expect(mock_publisher).to have_received(:publish).with(
          event_type: 'user.created',
          payload: hash_including(
            user_id: kind_of(String),
            email: 'newuser@example.com',
            name: 'New User',
          ),
        )
      end

      it 'includes correct user data in event payload' do
        allow(mock_publisher).to receive(:publish)

        described_class.create!(
          email: 'test@example.com',
          name: 'Test User',
          password: 'password123',
          password_confirmation: 'password123',
        )

        created_user = described_class.last
        expect(mock_publisher).to have_received(:publish) do |args|
          expect(args[:event_type]).to eq('user.created')
          expect(args[:payload][:user_id]).to eq(created_user.sub)
          expect(args[:payload][:email]).to eq('test@example.com')
          expect(args[:payload][:name]).to eq('Test User')
        end
      end

      context 'when event publish fails' do
        before do
          allow(mock_publisher).to receive(:publish).and_raise(
            Events::EventPublisher::PublishError.new('Kafka unavailable'),
          )
        end

        it 'does not fail user creation' do
          allow(Rails.logger).to receive(:error)

          expect do
            described_class.create!(
              email: 'test@example.com',
              name: 'Test User',
              password: 'password123',
              password_confirmation: 'password123',
            )
          end.not_to raise_error

          expect(Rails.logger).to have_received(:error).with(
            /Failed to publish user.created event for user/,
          )
        end

        it 'creates user successfully' do
          allow(Rails.logger).to receive(:error)

          user = described_class.create!(
            email: 'test@example.com',
            name: 'Test User',
            password: 'password123',
            password_confirmation: 'password123',
          )

          expect(user).to be_persisted
          expect(user.email).to eq('test@example.com')
        end
      end
    end

    describe 'on destroy' do
      let!(:user) do
        # Temporarily disable event publishing for setup
        allow(mock_publisher).to receive(:publish)

        described_class.create!(
          email: 'delete@example.com',
          name: 'Delete User',
          password: 'password123',
          password_confirmation: 'password123',
        )
      end

      it 'publishes user.deleted event after commit' do
        user_sub = user.sub
        allow(mock_publisher).to receive(:publish)

        user.destroy!

        expect(mock_publisher).to have_received(:publish).with(
          event_type: 'user.deleted',
          payload: {
            user_id: user_sub,
          },
        )
      end

      context 'when event publish fails' do
        before do
          allow(mock_publisher).to receive(:publish).with(
            event_type: 'user.deleted',
            payload: anything,
          ).and_raise(
            Events::EventPublisher::PublishError.new('Kafka unavailable'),
          )
        end

        it 'does not fail user deletion' do
          allow(Rails.logger).to receive(:error)

          expect { user.destroy! }.not_to raise_error

          expect(Rails.logger).to have_received(:error).with(
            /Failed to publish user.deleted event for user #{user.sub}/,
          )
        end

        it 'deletes user successfully' do
          allow(Rails.logger).to receive(:error)

          user.destroy!

          expect(described_class.find_by(id: user.id)).to be_nil
        end
      end
    end
  end

  describe 'validations' do
    it 'requires email' do
      user = described_class.new(password: 'password123', password_confirmation: 'password123')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'requires valid email format' do
      allow(mock_publisher).to receive(:publish)

      user = described_class.new(
        email: 'invalid-email',
        password: 'password123',
        password_confirmation: 'password123',
      )
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
    end

    it 'requires unique email' do
      allow(mock_publisher).to receive(:publish)

      described_class.create!(
        email: 'duplicate@example.com',
        password: 'password123',
        password_confirmation: 'password123',
      )

      user = described_class.new(
        email: 'duplicate@example.com',
        password: 'password123',
        password_confirmation: 'password123',
      )
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('has already been taken')
    end
  end

  describe 'sub generation' do
    it 'generates sub on create' do
      allow(mock_publisher).to receive(:publish)

      user = described_class.create!(
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123',
      )

      expect(user.sub).to be_present
      expect(user.sub).to match(/\A[0-9a-f-]{36}\z/) # UUID format
    end

    it 'ensures sub uniqueness' do
      allow(mock_publisher).to receive(:publish)

      user1 = described_class.create!(
        email: 'user1@example.com',
        password: 'password123',
        password_confirmation: 'password123',
      )

      user2 = described_class.create!(
        email: 'user2@example.com',
        password: 'password123',
        password_confirmation: 'password123',
      )

      expect(user1.sub).not_to eq(user2.sub)
    end
  end
end
