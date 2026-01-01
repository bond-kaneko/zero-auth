# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OIDC JWKS Endpoint', type: :request do
  describe 'GET /oidc/jwks' do
    it 'returns JSON Web Key Set with empty keys array' do
      get oidc_jwks_path

      expect(response).to have_http_status(:success)
      expect(response.parsed_body).to eq({ 'keys' => [] })
    end
  end
end
