# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OIDC Token Endpoint', type: :request do
  let(:client) { create(:client) }
  let(:user) { create(:user) }
  let(:valid_code) { create(:authorization_code, user: user, client: client) }

  def basic_auth_header(client_id, client_secret)
    credentials = Base64.strict_encode64("#{client_id}:#{client_secret}")
    { 'Authorization' => "Basic #{credentials}" }
  end

  describe 'POST /oidc/token' do
    context 'with valid authorization code and Basic auth' do
      it 'exchanges code for tokens' do
        post '/oidc/token', params: {
          grant_type: 'authorization_code',
          code: valid_code.code,
          redirect_uri: valid_code.redirect_uri,
        }, headers: basic_auth_header(client.client_id, client.client_secret)

        expect(response).to have_http_status(:success)

        json = response.parsed_body
        expect(json['token_type']).to eq('Bearer')
        expect(json['expires_in']).to eq(3600)
        expect(json['access_token']).to be_present
        expect(json['id_token']).to be_present
      end

      it 'marks authorization code as used' do
        post '/oidc/token', params: {
          grant_type: 'authorization_code',
          code: valid_code.code,
          redirect_uri: valid_code.redirect_uri,
        }, headers: basic_auth_header(client.client_id, client.client_secret)

        expect(response).to have_http_status(:success)

        valid_code.reload
        expect(valid_code.used).to be true
      end
    end

    context 'with valid authorization code and POST params auth' do
      it 'exchanges code for tokens' do
        post '/oidc/token', params: {
          grant_type: 'authorization_code',
          code: valid_code.code,
          redirect_uri: valid_code.redirect_uri,
          client_id: client.client_id,
          client_secret: client.client_secret,
        }, headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }

        expect(response).to have_http_status(:success)

        json = response.parsed_body
        expect(json['token_type']).to eq('Bearer')
        expect(json['access_token']).to be_present
        expect(json['id_token']).to be_present
      end
    end

    context 'with invalid grant_type' do
      it 'returns unsupported_grant_type error' do
        post '/oidc/token', params: {
          grant_type: 'refresh_token',
          code: valid_code.code,
          redirect_uri: valid_code.redirect_uri,
        }, headers: basic_auth_header(client.client_id, client.client_secret)

        expect(response).to have_http_status(:bad_request)

        json = response.parsed_body
        expect(json['error']).to eq('unsupported_grant_type')
        expect(json['error_description']).to include('authorization_code')
      end
    end

    context 'with missing code parameter' do
      it 'returns invalid_request error' do
        post '/oidc/token', params: {
          grant_type: 'authorization_code',
          redirect_uri: valid_code.redirect_uri,
        }, headers: basic_auth_header(client.client_id, client.client_secret)

        expect(response).to have_http_status(:bad_request)

        json = response.parsed_body
        expect(json['error']).to eq('invalid_request')
        expect(json['error_description']).to include('code')
      end
    end

    context 'with missing redirect_uri parameter' do
      it 'returns invalid_request error' do
        post '/oidc/token', params: {
          grant_type: 'authorization_code',
          code: valid_code.code,
        }, headers: basic_auth_header(client.client_id, client.client_secret)

        expect(response).to have_http_status(:bad_request)

        json = response.parsed_body
        expect(json['error']).to eq('invalid_request')
        expect(json['error_description']).to include('redirect_uri')
      end
    end

    context 'with invalid client credentials' do
      it 'returns invalid_client error' do
        post '/oidc/token', params: {
          grant_type: 'authorization_code',
          code: valid_code.code,
          redirect_uri: valid_code.redirect_uri,
        }, headers: basic_auth_header(client.client_id, 'wrong-secret')

        expect(response).to have_http_status(:bad_request)

        json = response.parsed_body
        expect(json['error']).to eq('invalid_client')
      end
    end

    context 'with expired authorization code' do
      let(:expired_code) { create(:authorization_code, :expired, user: user, client: client) }

      it 'returns invalid_grant error' do
        post '/oidc/token', params: {
          grant_type: 'authorization_code',
          code: expired_code.code,
          redirect_uri: expired_code.redirect_uri,
        }, headers: basic_auth_header(client.client_id, client.client_secret)

        expect(response).to have_http_status(:bad_request)

        json = response.parsed_body
        expect(json['error']).to eq('invalid_grant')
        expect(json['error_description']).to include('expired')
      end
    end

    context 'with already used authorization code' do
      let(:used_code) { create(:authorization_code, :used, user: user, client: client) }

      it 'returns invalid_grant error' do
        post '/oidc/token', params: {
          grant_type: 'authorization_code',
          code: used_code.code,
          redirect_uri: used_code.redirect_uri,
        }, headers: basic_auth_header(client.client_id, client.client_secret)

        expect(response).to have_http_status(:bad_request)

        json = response.parsed_body
        expect(json['error']).to eq('invalid_grant')
        expect(json['error_description']).to include('already been used')
      end
    end

    context 'with mismatched redirect_uri' do
      it 'returns invalid_grant error' do
        post '/oidc/token', params: {
          grant_type: 'authorization_code',
          code: valid_code.code,
          redirect_uri: 'https://different.com/callback',
        }, headers: basic_auth_header(client.client_id, client.client_secret)

        expect(response).to have_http_status(:bad_request)

        json = response.parsed_body
        expect(json['error']).to eq('invalid_grant')
        expect(json['error_description']).to include('Redirect URI does not match')
      end
    end
  end
end
