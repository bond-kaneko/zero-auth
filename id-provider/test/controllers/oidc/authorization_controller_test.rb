# frozen_string_literal: true

require 'test_helper'

module Oidc
  class AuthorizationControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:one)
      @client = clients(:active_client)
    end

    def login_as(user)
      post login_url, params: { email: user.email, password: 'Password123' }
    end

    test 'new redirects to login when not authenticated' do
      get oidc_authorize_url, params: {
        client_id: @client.client_id,
        redirect_uri: 'https://example.com/callback',
        response_type: 'code',
        scope: 'openid profile',
      }

      assert_redirected_to login_url
    end

    test 'new auto-approves when user has existing consent covering requested scopes' do
      login_as(@user)

      get oidc_authorize_url, params: {
        client_id: @client.client_id,
        redirect_uri: 'https://example.com/callback',
        response_type: 'code',
        scope: 'openid profile email',
        state: 'test-state',
      }

      assert_redirected_to(%r{\Ahttps://example\.com/callback\?code=})
      assert_match(/state=test-state/, response.location)
    end

    test 'new shows consent screen when no existing consent' do
      login_as(users(:two))

      get oidc_authorize_url, params: {
        client_id: @client.client_id,
        redirect_uri: 'https://example.com/callback',
        response_type: 'code',
        scope: 'openid profile',
        state: 'test-state',
      }

      assert_response :success
      assert_select 'form'
    end

    test 'new shows consent screen when requested scopes exceed existing consent' do
      login_as(@user)

      get oidc_authorize_url, params: {
        client_id: @client.client_id,
        redirect_uri: 'https://example.com/callback',
        response_type: 'code',
        scope: 'openid profile email admin',
        state: 'test-state',
      }

      assert_response :success
      assert_select 'form'
    end

    test 'create returns error when not authenticated' do
      post oidc_authorize_url, params: { approve: 'true' }

      assert_response :bad_request
      assert_includes response.body, 'Session expired'
    end

    test 'create handles approval and redirects with authorization code' do
      login_as(users(:two))

      get oidc_authorize_url, params: {
        client_id: @client.client_id,
        redirect_uri: 'https://example.com/callback',
        response_type: 'code',
        scope: 'openid profile',
        state: 'test-state',
      }

      post oidc_authorize_url, params: { approve: 'true' }

      assert_redirected_to(%r{\Ahttps://example\.com/callback\?code=})
      assert_match(/state=test-state/, response.location)

      consent = UserConsent.find_by(user: users(:two), client: @client)
      assert_not_nil consent
      assert_includes consent.scopes, 'openid'
      assert_includes consent.scopes, 'profile'
    end

    test 'create handles denial and redirects with error' do
      login_as(users(:two))

      get oidc_authorize_url, params: {
        client_id: @client.client_id,
        redirect_uri: 'https://example.com/callback',
        response_type: 'code',
        scope: 'openid profile',
        state: 'test-state',
      }

      post oidc_authorize_url, params: { approve: 'false' }

      expected_url = 'https://example.com/callback?error=access_denied&' \
                     'error_description=The+user+denied+the+request&state=test-state'
      assert_redirected_to expected_url
    end

    test 'create returns error when session expired' do
      login_as(@user)

      post oidc_authorize_url, params: { approve: 'true' }

      assert_response :bad_request
      assert_includes response.body, 'invalid_request'
      assert_includes response.body, 'Session expired'
    end

    test 'create clears authorization params from session after redirect' do
      login_as(users(:two))

      get oidc_authorize_url, params: {
        client_id: @client.client_id,
        redirect_uri: 'https://example.com/callback',
        response_type: 'code',
        scope: 'openid profile',
      }

      assert_not_nil session[:authorization_params]

      post oidc_authorize_url, params: { approve: 'true' }

      assert_nil session[:authorization_params]
    end
  end
end
