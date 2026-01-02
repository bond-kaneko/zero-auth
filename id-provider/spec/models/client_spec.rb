# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Client, type: :model do
  describe '#regenerate_secret' do
    let(:client) { create(:client) }

    it 'generates a new client secret and returns true' do
      old_secret = client.client_secret

      result = client.regenerate_secret

      expect(result).to be true
      expect(client.client_secret).not_to eq(old_secret)
      expect(client.client_secret).to be_present
      expect(client.client_secret.length).to eq(64) # SecureRandom.hex(32) generates 64 characters
    end

    it 'persists the new secret to database' do
      client.regenerate_secret

      expect(client.reload.client_secret).to eq(client.client_secret)
    end

    context 'when save fails' do
      it 'returns false' do
        allow(client).to receive(:save).and_return(false)

        result = client.regenerate_secret

        expect(result).to be false
      end
    end
  end
end
