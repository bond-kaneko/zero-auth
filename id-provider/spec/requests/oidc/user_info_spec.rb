# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OIDC UserInfo Endpoint', type: :request do
  let(:user) { create(:user) }
  let(:client) { create(:client) }

  describe 'GET /oidc/userinfo' do
    context 'with valid access token and openid scope only' do
      let(:access_token) { create(:access_token, :openid_only, user: user, client: client) }

      it 'returns only sub claim' do
        get oidc_userinfo_path, headers: { 'Authorization' => "Bearer #{access_token.token}" }

        expect(response).to have_http_status(:success)
        json = response.parsed_body
        expect(json).to include('sub' => user.sub)
        expect(json).not_to have_key('email')
        expect(json).not_to have_key('name')
      end
    end

    context 'with valid access token and profile scope' do
      let(:access_token) { create(:access_token, :with_profile, user: user, client: client) }

      it 'returns sub and profile claims' do
        get oidc_userinfo_path, headers: { 'Authorization' => "Bearer #{access_token.token}" }

        expect(response).to have_http_status(:success)
        json = response.parsed_body
        expect(json['sub']).to eq(user.sub)
        expect(json).not_to have_key('email')
      end
    end

    context 'with valid access token and email scope' do
      let(:access_token) { create(:access_token, :with_email, user: user, client: client) }

      it 'returns sub and email claims' do
        get oidc_userinfo_path, headers: { 'Authorization' => "Bearer #{access_token.token}" }

        expect(response).to have_http_status(:success)
        json = response.parsed_body
        expect(json).to include(
          'sub' => user.sub,
          'email' => user.email,
        )
        expect(json).to have_key('email_verified')
        expect(json).not_to have_key('name')
      end
    end

    context 'with valid access token and all scopes' do
      let(:access_token) { create(:access_token, user: user, client: client) }

      it 'returns all available claims' do
        get oidc_userinfo_path, headers: { 'Authorization' => "Bearer #{access_token.token}" }

        expect(response).to have_http_status(:success)
        json = response.parsed_body
        expect(json).to include(
          'sub' => user.sub,
          'email' => user.email,
        )
        expect(json).to have_key('email_verified')
      end
    end
  end
end
