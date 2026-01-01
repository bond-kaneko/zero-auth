# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Oidc::BearerTokenValidation do
  let(:test_controller_class) do
    Class.new(ApplicationController) do
      include Oidc::BearerTokenValidation

      attr_accessor :request

      def initialize
        super
        @request = Struct.new(:headers).new({})
      end
    end
  end

  let(:controller) { test_controller_class.new }
  let(:user) { create(:user) }
  let(:client) { create(:client) }

  describe '#extract_bearer_token' do
    context 'when Authorization header is missing' do
      it 'returns invalid_token error' do
        error = controller.send(:extract_bearer_token)

        expect(error[:code]).to eq('invalid_token')
        expect(error[:description]).to include('Authorization header')
      end
    end

    context 'when Authorization header does not start with Bearer' do
      it 'returns invalid_token error' do
        controller.request.headers['Authorization'] = 'Basic some-credentials'

        error = controller.send(:extract_bearer_token)

        expect(error[:code]).to eq('invalid_token')
        expect(error[:description]).to include('Authorization header')
      end
    end

    context 'when Bearer token is blank' do
      it 'returns invalid_token error' do
        controller.request.headers['Authorization'] = 'Bearer '

        error = controller.send(:extract_bearer_token)

        expect(error[:code]).to eq('invalid_token')
        expect(error[:description]).to include('Missing access token')
      end
    end

    context 'when Bearer token is present' do
      it 'returns nil and sets @token_value' do
        controller.request.headers['Authorization'] = 'Bearer test-token-123'

        error = controller.send(:extract_bearer_token)

        expect(error).to be_nil
        expect(controller.instance_variable_get(:@token_value)).to eq('test-token-123')
      end
    end
  end

  describe '#verify_access_token' do
    before do
      controller.instance_variable_set(:@token_value, 'test-token')
    end

    context 'when access token does not exist' do
      it 'returns invalid_token error' do
        error = controller.send(:verify_access_token)

        expect(error[:code]).to eq('invalid_token')
        expect(error[:description]).to include('Invalid access token')
      end
    end

    context 'when access token has expired' do
      it 'returns invalid_token error' do
        create(:access_token, :expired, user: user, client: client, token: 'test-token')

        error = controller.send(:verify_access_token)

        expect(error[:code]).to eq('invalid_token')
        expect(error[:description]).to include('expired')
      end
    end

    context 'when access token is valid' do
      it 'returns nil and sets @access_token' do
        valid_token = create(:access_token, user: user, client: client, token: 'test-token')

        error = controller.send(:verify_access_token)

        expect(error).to be_nil
        expect(controller.instance_variable_get(:@access_token)).to eq(valid_token)
      end
    end
  end
end
