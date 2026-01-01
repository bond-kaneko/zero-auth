# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Oidc::RequestValidation do
  let(:test_controller_class) do
    Class.new(ApplicationController) do
      include Oidc::RequestValidation

      attr_accessor :params

      def initialize
        super
        @params = {}
      end
    end
  end

  let(:controller) { test_controller_class.new }

  describe '#validate_required_params' do
    context 'when client_id is missing' do
      it 'returns invalid_request error' do
        controller.params = { redirect_uri: 'https://example.com', response_type: 'code' }
        error = controller.send(:validate_required_params)

        expect(error[:code]).to eq('invalid_request')
        expect(error[:description]).to eq('Missing required parameter: client_id')
      end
    end

    context 'when redirect_uri is missing' do
      it 'returns invalid_request error' do
        controller.params = { client_id: 'test', response_type: 'code' }
        error = controller.send(:validate_required_params)

        expect(error[:code]).to eq('invalid_request')
        expect(error[:description]).to eq('Missing required parameter: redirect_uri')
      end
    end

    context 'when response_type is missing' do
      it 'returns invalid_request error' do
        controller.params = { client_id: 'test', redirect_uri: 'https://example.com' }
        error = controller.send(:validate_required_params)

        expect(error[:code]).to eq('invalid_request')
        expect(error[:description]).to eq('Missing required parameter: response_type')
      end
    end

    context 'when all required params present' do
      it 'returns nil' do
        controller.params = { client_id: 'test', redirect_uri: 'https://example.com', response_type: 'code' }
        error = controller.send(:validate_required_params)

        expect(error).to be_nil
      end
    end
  end

  describe '#validate_response_type' do
    context 'when response_type is not code' do
      it 'returns unsupported_response_type error' do
        controller.params = { response_type: 'token' }
        error = controller.send(:validate_response_type)

        expect(error[:code]).to eq('unsupported_response_type')
        expect(error[:description]).to eq('Only "code" response type is supported')
      end
    end

    context 'when response_type is code' do
      it 'returns nil' do
        controller.params = { response_type: 'code' }
        error = controller.send(:validate_response_type)

        expect(error).to be_nil
      end
    end
  end

  describe '#validate_scope' do
    context 'when scope is blank' do
      it 'returns invalid_scope error' do
        controller.params = { scope: '' }
        error = controller.send(:validate_scope)

        expect(error[:code]).to eq('invalid_scope')
        expect(error[:description]).to eq('The "openid" scope is required')
      end
    end

    context 'when openid scope is missing' do
      it 'returns invalid_scope error' do
        controller.params = { scope: 'profile email' }
        error = controller.send(:validate_scope)

        expect(error[:code]).to eq('invalid_scope')
        expect(error[:description]).to eq('The "openid" scope is required')
      end
    end

    context 'when openid scope is present' do
      it 'returns nil' do
        controller.params = { scope: 'openid profile email' }
        error = controller.send(:validate_scope)

        expect(error).to be_nil
      end
    end
  end

  describe '#parse_scopes' do
    context 'when scope_string is blank' do
      it 'returns empty array' do
        scopes = controller.send(:parse_scopes, '')

        expect(scopes).to eq([])
      end
    end

    context 'when scope_string has multiple scopes' do
      it 'returns array of scopes' do
        scopes = controller.send(:parse_scopes, 'openid profile email')

        expect(scopes).to eq(%w[openid profile email])
      end
    end
  end

  describe '#build_query_string' do
    it 'builds query string from hash' do
      query = controller.send(:build_query_string, { code: 'test-code', state: 'test-state' })

      expect(query).to eq('code=test-code&state=test-state')
    end

    it 'ignores nil values' do
      query = controller.send(:build_query_string, { code: 'test-code', state: nil })

      expect(query).to eq('code=test-code')
    end

    it 'escapes special characters' do
      query = controller.send(:build_query_string, { error_description: 'Missing required parameter: client_id' })

      expect(query).to eq('error_description=Missing+required+parameter%3A+client_id')
    end
  end
end
