# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserConsent, type: :model do
  describe '.record_for' do
    let(:user) { create(:user) }
    let(:client) { create(:client) }
    let(:scopes) { %w[openid profile email] }

    context 'when consent does not exist' do
      it 'creates a new consent record' do
        expect do
          described_class.record_for(user: user, client: client, scopes: scopes)
        end.to change(described_class, :count).by(1)
      end

      it 'sets the scopes and returns the consent' do
        consent = described_class.record_for(user: user, client: client, scopes: scopes)

        expect(consent).to be_persisted
        expect(consent.user).to eq(user)
        expect(consent.client).to eq(client)
        expect(consent.scopes).to eq(scopes)
        expect(consent.expires_at).to be_nil
      end
    end

    context 'when consent already exists' do
      let!(:existing_consent) do
        create(:user_consent, user: user, client: client, scopes: %w[openid], expires_at: 1.day.from_now)
      end

      it 'does not create a new consent record' do
        expect do
          described_class.record_for(user: user, client: client, scopes: scopes)
        end.not_to change(described_class, :count)
      end

      it 'updates the existing consent with new scopes and clears expires_at' do
        consent = described_class.record_for(user: user, client: client, scopes: scopes)

        expect(consent.id).to eq(existing_consent.id)
        expect(consent.scopes).to eq(scopes)
        expect(consent.expires_at).to be_nil
      end
    end

    context 'when save fails' do
      it 'raises ActiveRecord::RecordInvalid' do
        allow_any_instance_of(described_class).to receive(:save!).and_raise(
          ActiveRecord::RecordInvalid.new(described_class.new),
        )

        expect do
          described_class.record_for(user: user, client: client, scopes: scopes)
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
