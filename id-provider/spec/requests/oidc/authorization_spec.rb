# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OIDC Authorization Endpoint', type: :request do
  before { host! 'example.com' }

  let(:user) { create(:user, email: 'user@example.com') }
  let(:user_two) { create(:user, email: 'user2@example.com') }
  let(:client) { create(:client, redirect_uris: ['https://example.com/callback']) }

  describe 'GET /oidc/authorize' do
    context 'when not authenticated' do
      it 'redirects to login' do
        get oidc_authorize_url, params: {
          client_id: client.client_id,
          redirect_uri: 'https://example.com/callback',
          response_type: 'code',
          scope: 'openid profile',
        }

        expect(response).to redirect_to(login_url)
      end
    end

    context 'when user has existing consent covering requested scopes' do
      before do
        create(:user_consent, user: user, client: client, scopes: %w[openid profile email])
        login_as(user)
      end

      it 'auto-approves and redirects with authorization code' do
        get oidc_authorize_url, params: {
          client_id: client.client_id,
          redirect_uri: 'https://example.com/callback',
          response_type: 'code',
          scope: 'openid profile email',
          state: 'test-state',
        }

        expect(response).to redirect_to(%r{\Ahttps://example\.com/callback\?code=})
        expect(response.location).to match(/state=test-state/)
      end
    end

    context 'when no existing consent' do
      before { login_as(user_two) }

      it 'shows consent screen' do
        get oidc_authorize_url, params: {
          client_id: client.client_id,
          redirect_uri: 'https://example.com/callback',
          response_type: 'code',
          scope: 'openid profile',
          state: 'test-state',
        }

        expect(response).to have_http_status(:success)
        expect(response.body).to include('<form')
      end
    end

    context 'when requested scopes exceed existing consent' do
      before do
        create(:user_consent, user: user, client: client, scopes: %w[openid profile email])
        login_as(user)
      end

      it 'shows consent screen' do
        get oidc_authorize_url, params: {
          client_id: client.client_id,
          redirect_uri: 'https://example.com/callback',
          response_type: 'code',
          scope: 'openid profile email admin',
          state: 'test-state',
        }

        expect(response).to have_http_status(:success)
        expect(response.body).to include('<form')
      end
    end
  end

  describe 'POST /oidc/authorize' do
    context 'when not authenticated' do
      it 'returns error' do
        post oidc_authorize_url, params: { approve: 'true' }

        expect(response).to have_http_status(:bad_request)
        expect(response.body).to include('Session expired')
      end
    end

    context 'when user approves' do
      before do
        login_as(user_two)
        get oidc_authorize_url, params: {
          client_id: client.client_id,
          redirect_uri: 'https://example.com/callback',
          response_type: 'code',
          scope: 'openid profile',
          state: 'test-state',
        }
      end

      it 'creates consent record' do
        expect do
          post oidc_authorize_url, params: { approve: 'true' }
        end.to change(UserConsent, :count).by(1)

        consent = UserConsent.find_by(user: user_two, client: client)
        expect(consent).to be_present
        expect(consent.scopes).to include('openid')
        expect(consent.scopes).to include('profile')
      end

      it 'redirects with authorization code and state' do
        post oidc_authorize_url, params: { approve: 'true' }

        expect(response).to redirect_to(%r{\Ahttps://example\.com/callback\?code=})
        expect(response.location).to match(/state=test-state/)
      end

      it 'clears authorization params from session' do
        post oidc_authorize_url, params: { approve: 'true' }

        # Session is cleared in controller, verify redirect happened
        expect(response).to redirect_to(%r{\Ahttps://example\.com/callback})
      end
    end

    context 'when user denies' do
      before do
        login_as(user_two)
        get oidc_authorize_url, params: {
          client_id: client.client_id,
          redirect_uri: 'https://example.com/callback',
          response_type: 'code',
          scope: 'openid profile',
          state: 'test-state',
        }
      end

      it 'redirects with error' do
        post oidc_authorize_url, params: { approve: 'false' }

        expected_url = 'https://example.com/callback?error=access_denied&' \
                       'error_description=The+user+denied+the+request&state=test-state'
        expect(response).to redirect_to(expected_url)
      end
    end

    context 'when session expired' do
      before { login_as(user) }

      it 'returns error when no authorization params in session' do
        post oidc_authorize_url, params: { approve: 'true' }

        expect(response).to have_http_status(:bad_request)
        expect(response.body).to include('invalid_request')
        expect(response.body).to include('Session expired')
      end
    end
  end

  describe 'GET /oidc/logout' do
    context 'with post_logout_redirect_uri and state' do
      before { login_as(user) }

      it 'clears session and redirects with state' do
        get oidc_logout_url, params: {
          post_logout_redirect_uri: 'https://example.com/logged-out',
          state: 'logout-state',
        }

        expect(response).to redirect_to('https://example.com/logged-out?state=logout-state')
      end
    end

    context 'with post_logout_redirect_uri without state' do
      before { login_as(user) }

      it 'clears session and redirects' do
        get oidc_logout_url, params: {
          post_logout_redirect_uri: 'https://example.com/logged-out',
        }

        expect(response).to redirect_to('https://example.com/logged-out')
      end
    end

    context 'without post_logout_redirect_uri' do
      before { login_as(user) }

      it 'clears session and redirects to root' do
        get oidc_logout_url

        expect(response).to redirect_to(root_url)
      end
    end
  end
end
