# frozen_string_literal: true

require 'test_helper'

module Oidc
  class TokenValidationTest < ActiveSupport::TestCase
    class TestController < ApplicationController
      include Oidc::TokenValidation

      attr_accessor :params, :request

      def initialize
        super
        @params = {}
        @request = Struct.new(:headers).new({})
      end
    end

    def setup
      @controller = TestController.new
      @client = clients(:active_client)
    end

    describe '#validate_token_params' do
      before do
        @controller = TestController.new
      end

      it 'returns error when grant_type is not authorization_code' do
        @controller.params = {
          grant_type: 'refresh_token',
          code: 'test-code',
          redirect_uri: 'https://example.com/callback',
        }

        error = @controller.send(:validate_token_params)

        assert_equal 'unsupported_grant_type', error[:code]
        assert_includes error[:description], 'authorization_code'
      end

      it 'returns error when code is missing' do
        @controller.params = {
          grant_type: 'authorization_code',
          redirect_uri: 'https://example.com/callback',
        }

        error = @controller.send(:validate_token_params)

        assert_equal 'invalid_request', error[:code]
        assert_includes error[:description], 'code'
      end

      it 'returns error when redirect_uri is missing' do
        @controller.params = {
          grant_type: 'authorization_code',
          code: 'test-code',
        }

        error = @controller.send(:validate_token_params)

        assert_equal 'invalid_request', error[:code]
        assert_includes error[:description], 'redirect_uri'
      end

      it 'returns nil when all required params are present' do
        @controller.params = {
          grant_type: 'authorization_code',
          code: 'test-code',
          redirect_uri: 'https://example.com/callback',
        }

        error = @controller.send(:validate_token_params)

        assert_nil error
      end
    end

    describe '#extract_client_credentials' do
      before do
        @controller = TestController.new
        @client = clients(:active_client)
      end

      it 'extracts from Basic auth header' do
        credentials = Base64.strict_encode64("#{@client.client_id}:#{@client.client_secret}")
        @controller.request.headers['Authorization'] = "Basic #{credentials}"

        client_id, client_secret = @controller.send(:extract_client_credentials)

        assert_equal @client.client_id, client_id
        assert_equal @client.client_secret, client_secret
      end

      it 'extracts from POST params' do
        @controller.params = {
          client_id: @client.client_id,
          client_secret: @client.client_secret,
        }

        client_id, client_secret = @controller.send(:extract_client_credentials)

        assert_equal @client.client_id, client_id
        assert_equal @client.client_secret, client_secret
      end
    end

    describe '#authenticate_client' do
      before do
        @controller = TestController.new
        @client = clients(:active_client)
      end

      it 'returns error when client_id is invalid' do
        @controller.params = {
          client_id: 'invalid-client-id',
          client_secret: 'some-secret',
        }

        error = @controller.send(:authenticate_client)

        assert_equal 'invalid_client', error[:code]
        assert_includes error[:description], 'client_id'
      end

      it 'returns error when client is not active' do
        inactive_client = clients(:inactive_client)
        @controller.params = {
          client_id: inactive_client.client_id,
          client_secret: inactive_client.client_secret,
        }

        error = @controller.send(:authenticate_client)

        assert_equal 'invalid_client', error[:code]
        assert_includes error[:description], 'not active'
      end

      it 'returns error when client_secret is invalid' do
        @controller.params = {
          client_id: @client.client_id,
          client_secret: 'invalid-secret',
        }

        error = @controller.send(:authenticate_client)

        assert_equal 'invalid_client', error[:code]
        assert_includes error[:description], 'client_secret'
      end

      it 'returns nil when credentials are valid' do
        @controller.params = {
          client_id: @client.client_id,
          client_secret: @client.client_secret,
        }

        error = @controller.send(:authenticate_client)

        assert_nil error
      end
    end

    describe '#verify_authorization_code' do
      before do
        @controller = TestController.new
        @client = clients(:active_client)
      end

      it 'returns error when code does not exist' do
        @controller.params = { code: 'non-existent-code', redirect_uri: 'https://example.com/callback' }
        @controller.instance_variable_set(:@client, @client)

        error = @controller.send(:verify_authorization_code)

        assert_equal 'invalid_grant', error[:code]
        assert_includes error[:description], 'Invalid authorization code'
      end

      it 'returns error when code has expired' do
        expired_code = authorization_codes(:expired_code)
        @controller.params = { code: expired_code.code, redirect_uri: expired_code.redirect_uri }
        @controller.instance_variable_set(:@client, @client)

        error = @controller.send(:verify_authorization_code)

        assert_equal 'invalid_grant', error[:code]
        assert_includes error[:description], 'expired'
      end

      it 'returns error when code has already been used' do
        used_code = authorization_codes(:used_code)
        @controller.params = { code: used_code.code, redirect_uri: used_code.redirect_uri }
        @controller.instance_variable_set(:@client, @client)

        error = @controller.send(:verify_authorization_code)

        assert_equal 'invalid_grant', error[:code]
        assert_includes error[:description], 'already been used'
      end

      it 'returns error when redirect_uri does not match' do
        valid_code = authorization_codes(:valid_code)
        @controller.params = { code: valid_code.code, redirect_uri: 'https://different.com/callback' }
        @controller.instance_variable_set(:@client, @client)

        error = @controller.send(:verify_authorization_code)

        assert_equal 'invalid_grant', error[:code]
        assert_includes error[:description], 'Redirect URI does not match'
      end

      it 'returns nil when code is valid' do
        valid_code = authorization_codes(:valid_code)
        @controller.params = { code: valid_code.code, redirect_uri: valid_code.redirect_uri }
        @controller.instance_variable_set(:@client, @client)

        error = @controller.send(:verify_authorization_code)

        assert_nil error
      end
    end
  end
end
