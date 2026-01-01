# frozen_string_literal: true

require 'test_helper'

module Oidc
  class TokenControllerTest < ActionDispatch::IntegrationTest
    def setup
      @client = clients(:active_client)
      @valid_code = authorization_codes(:valid_code)
    end

    def basic_auth_header(client_id, client_secret)
      credentials = Base64.strict_encode64("#{client_id}:#{client_secret}")
      { 'Authorization' => "Basic #{credentials}" }
    end

    test 'exchanges valid authorization code for tokens with Basic auth' do
      post oidc_token_url, params: {
        grant_type: 'authorization_code',
        code: @valid_code.code,
        redirect_uri: @valid_code.redirect_uri,
      }, headers: basic_auth_header(@client.client_id, @client.client_secret)

      assert_response :success
      json = response.parsed_body

      assert_equal 'Bearer', json['token_type']
      assert_equal 3600, json['expires_in']
      assert_not_nil json['access_token']
      assert_not_nil json['id_token']
    end

    test 'exchanges valid authorization code for tokens with POST params auth' do
      post oidc_token_url, params: {
        grant_type: 'authorization_code',
        code: @valid_code.code,
        redirect_uri: @valid_code.redirect_uri,
        client_id: @client.client_id,
        client_secret: @client.client_secret,
      }

      assert_response :success
      json = response.parsed_body

      assert_equal 'Bearer', json['token_type']
      assert_not_nil json['access_token']
      assert_not_nil json['id_token']
    end

    test 'marks authorization code as used after successful exchange' do
      post oidc_token_url, params: {
        grant_type: 'authorization_code',
        code: @valid_code.code,
        redirect_uri: @valid_code.redirect_uri,
      }, headers: basic_auth_header(@client.client_id, @client.client_secret)

      assert_response :success

      @valid_code.reload
      assert @valid_code.used
    end
  end
end
