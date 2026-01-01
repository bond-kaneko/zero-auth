# frozen_string_literal: true

require 'test_helper'

module Oidc
  class RequestValidationTest < ActiveSupport::TestCase
    class TestController < ApplicationController
      include Oidc::RequestValidation

      attr_accessor :params

      def initialize
        super
        @params = {}
      end
    end

    def setup
      @controller = TestController.new
    end

    describe '#validate_required_params' do
      it 'returns error when client_id is missing' do
        @controller.params = { redirect_uri: 'https://example.com', response_type: 'code' }
        error = @controller.send(:validate_required_params)

        assert_equal 'invalid_request', error[:code]
        assert_equal 'Missing required parameter: client_id', error[:description]
      end

      it 'returns error when redirect_uri is missing' do
        @controller.params = { client_id: 'test', response_type: 'code' }
        error = @controller.send(:validate_required_params)

        assert_equal 'invalid_request', error[:code]
        assert_equal 'Missing required parameter: redirect_uri', error[:description]
      end

      it 'returns error when response_type is missing' do
        @controller.params = { client_id: 'test', redirect_uri: 'https://example.com' }
        error = @controller.send(:validate_required_params)

        assert_equal 'invalid_request', error[:code]
        assert_equal 'Missing required parameter: response_type', error[:description]
      end

      it 'returns nil when all required params present' do
        @controller.params = { client_id: 'test', redirect_uri: 'https://example.com', response_type: 'code' }
        error = @controller.send(:validate_required_params)

        assert_nil error
      end
    end

    describe '#validate_response_type' do
      it 'returns error when response_type is not code' do
        @controller.params = { response_type: 'token' }
        error = @controller.send(:validate_response_type)

        assert_equal 'unsupported_response_type', error[:code]
        assert_equal 'Only "code" response type is supported', error[:description]
      end

      it 'returns nil when response_type is code' do
        @controller.params = { response_type: 'code' }
        error = @controller.send(:validate_response_type)

        assert_nil error
      end
    end

    describe '#validate_scope' do
      it 'returns error when scope is blank' do
        @controller.params = { scope: '' }
        error = @controller.send(:validate_scope)

        assert_equal 'invalid_scope', error[:code]
        assert_equal 'The "openid" scope is required', error[:description]
      end

      it 'returns error when openid scope is missing' do
        @controller.params = { scope: 'profile email' }
        error = @controller.send(:validate_scope)

        assert_equal 'invalid_scope', error[:code]
        assert_equal 'The "openid" scope is required', error[:description]
      end

      it 'returns nil when openid scope is present' do
        @controller.params = { scope: 'openid profile email' }
        error = @controller.send(:validate_scope)

        assert_nil error
      end
    end

    describe '#parse_scopes' do
      it 'returns empty array when scope_string is blank' do
        scopes = @controller.send(:parse_scopes, '')

        assert_equal [], scopes
      end

      it 'returns array of scopes' do
        scopes = @controller.send(:parse_scopes, 'openid profile email')

        assert_equal %w[openid profile email], scopes
      end
    end

    describe '#build_query_string' do
      it 'builds query string from hash' do
        query = @controller.send(:build_query_string, { code: 'test-code', state: 'test-state' })

        assert_equal 'code=test-code&state=test-state', query
      end

      it 'ignores nil values' do
        query = @controller.send(:build_query_string, { code: 'test-code', state: nil })

        assert_equal 'code=test-code', query
      end

      it 'escapes special characters' do
        query = @controller.send(:build_query_string, { error_description: 'Missing required parameter: client_id' })

        assert_equal 'error_description=Missing+required+parameter%3A+client_id', query
      end
    end
  end
end
