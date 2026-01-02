# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OidcConfigurationPresenter do
  describe '#to_json' do
    let(:issuer) { 'https://id-provider.example.com:3443' }

    it 'returns OIDC Discovery document with all required fields' do
      presenter = described_class.new(issuer: issuer)
      result = presenter.to_json

      expect(result).to eq(
        {
          issuer: 'https://id-provider.example.com:3443',
          authorization_endpoint: 'https://id-provider.example.com:3443/oidc/authorize',
          token_endpoint: 'https://id-provider.example.com:3443/oidc/token',
          userinfo_endpoint: 'https://id-provider.example.com:3443/oidc/userinfo',
          jwks_uri: 'https://id-provider.example.com:3443/oidc/jwks',
          end_session_endpoint: 'https://id-provider.example.com:3443/oidc/logout',
          response_types_supported: ['code'],
          subject_types_supported: ['public'],
          id_token_signing_alg_values_supported: ['RS256'],
          scopes_supported: %w[openid profile email],
        },
      )
    end

    context 'with different issuer URL' do
      let(:issuer) { 'https://another-issuer.com' }

      it 'builds endpoints based on provided issuer' do
        presenter = described_class.new(issuer: issuer)
        result = presenter.to_json

        expect(result[:issuer]).to eq('https://another-issuer.com')
        expect(result[:authorization_endpoint]).to eq('https://another-issuer.com/oidc/authorize')
        expect(result[:token_endpoint]).to eq('https://another-issuer.com/oidc/token')
      end
    end
  end
end
