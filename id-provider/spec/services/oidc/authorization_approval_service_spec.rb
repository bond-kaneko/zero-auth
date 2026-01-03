# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Oidc::AuthorizationApprovalService do
  let(:user) { create(:user) }
  let(:client) { create(:client) }
  let(:authorization_params) do
    {
      'client_id' => client.client_id,
      'redirect_uri' => 'https://example.com/callback',
      'response_type' => 'code',
      'scope' => 'openid profile email',
      'state' => 'random-state',
      'nonce' => 'random-nonce',
    }
  end
  let(:service) { described_class.new(user, client, authorization_params) }

  describe '#approve' do
    it 'generates an authorization code' do
      result = service.approve

      expect(result[:authorization_code]).to be_a(AuthorizationCode)
      expect(result[:authorization_code].user).to eq(user)
      expect(result[:authorization_code].client).to eq(client)
    end

    it 'records user consent' do
      expect do
        service.approve
      end.to change(UserConsent, :count).by(1)

      consent = UserConsent.last
      expect(consent.user).to eq(user)
      expect(consent.client).to eq(client)
      expect(consent.scopes).to contain_exactly('openid', 'profile', 'email')
    end

    it 'returns redirect URI with authorization code' do
      result = service.approve

      expect(result[:redirect_uri]).to include('https://example.com/callback')
      expect(result[:redirect_uri]).to include('code=')
      expect(result[:redirect_uri]).to include('state=random-state')
    end

    context 'when user already has consent' do
      before do
        UserConsent.create!(
          user: user,
          client: client,
          scopes: %w[openid profile],
        )
      end

      it 'updates existing consent with new scopes' do
        expect do
          service.approve
        end.not_to change(UserConsent, :count)

        consent = UserConsent.last
        expect(consent.scopes).to contain_exactly('openid', 'profile', 'email')
      end
    end
  end

  describe '#deny' do
    it 'returns redirect URI with error' do
      result = service.deny

      expect(result[:redirect_uri]).to include('https://example.com/callback')
      expect(result[:redirect_uri]).to include('error=access_denied')
      expect(result[:redirect_uri]).to include('state=random-state')
    end

    it 'does not create authorization code' do
      expect do
        service.deny
      end.not_to change(AuthorizationCode, :count)
    end

    it 'does not record user consent' do
      expect do
        service.deny
      end.not_to change(UserConsent, :count)
    end
  end
end
