# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OIDC Discovery Endpoint', type: :request do
  describe 'GET /.well-known/openid-configuration' do
    it 'returns valid OIDC discovery document with all required fields' do
      get '/.well-known/openid-configuration'

      json = response.parsed_body
      issuer = ENV.fetch('OIDC_ISSUER', 'https://id-provider.local:3443')

      expect(json).to include(
        'issuer' => issuer,
        'authorization_endpoint' => "#{issuer}/oidc/authorize",
        'token_endpoint' => "#{issuer}/oidc/token",
        'userinfo_endpoint' => "#{issuer}/oidc/userinfo",
        'jwks_uri' => "#{issuer}/oidc/jwks",
        'end_session_endpoint' => "#{issuer}/oidc/logout",
        'response_types_supported' => ['code'],
        'subject_types_supported' => ['public'],
        'id_token_signing_alg_values_supported' => ['RS256'],
        'scopes_supported' => %w[openid profile email],
      )
    end
  end
end
