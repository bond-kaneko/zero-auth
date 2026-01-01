# frozen_string_literal: true

require 'test_helper'

module Oidc
  class ClientValidationsTest < ActiveSupport::TestCase
    class TestController < ApplicationController
      include Oidc::ClientValidations

      attr_accessor :params

      def initialize
        super
        @params = {}
      end
    end

    def setup
      @controller = TestController.new
      @client = clients(:active_client)
      @inactive_client = clients(:inactive_client)
    end

    describe '#validate_client' do
      it 'returns error when client is nil' do
        @controller.params = { redirect_uri: 'https://example.com', response_type: 'code' }
        error = @controller.send(:validate_client, nil)

        assert_equal 'invalid_client', error[:code]
        assert_equal 'Invalid client_id', error[:description]
      end

      it 'returns error when client is not active' do
        @controller.params = { redirect_uri: 'https://inactive.com/callback', response_type: 'code' }
        error = @controller.send(:validate_client, @inactive_client)

        assert_equal 'invalid_client', error[:code]
        assert_equal 'Client is not active', error[:description]
      end

      it 'returns error when redirect_uri is invalid' do
        @controller.params = { redirect_uri: 'https://malicious.com/callback', response_type: 'code' }
        error = @controller.send(:validate_client, @client)

        assert_equal 'invalid_request', error[:code]
        assert_equal 'Invalid redirect_uri', error[:description]
      end

      it 'returns error when response_type is not supported' do
        @controller.params = { redirect_uri: 'https://example.com/callback', response_type: 'token' }
        error = @controller.send(:validate_client, @client)

        assert_equal 'unsupported_response_type', error[:code]
        assert_equal 'Client does not support this response_type', error[:description]
      end

      it 'returns nil when all validations pass' do
        @controller.params = { redirect_uri: 'https://example.com/callback', response_type: 'code' }
        error = @controller.send(:validate_client, @client)

        assert_nil error
      end
    end
  end
end
