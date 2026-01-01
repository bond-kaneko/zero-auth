# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Oidc::ClientValidations do
  # Test controller to include the concern
  let(:test_controller_class) do
    Class.new(ApplicationController) do
      include Oidc::ClientValidations

      attr_accessor :params

      def initialize
        super
        @params = {}
      end
    end
  end

  let(:controller) { test_controller_class.new }
  let(:client) { create(:client, redirect_uris: ['https://example.com/callback'], response_types: ['code']) }
  let(:inactive_client) { create(:client, :inactive, redirect_uris: ['https://inactive.com/callback']) }

  describe '#validate_client' do
    context 'when client is nil' do
      it 'returns invalid_client error' do
        controller.params = { redirect_uri: 'https://example.com', response_type: 'code' }
        error = controller.send(:validate_client, nil)

        expect(error[:code]).to eq('invalid_client')
        expect(error[:description]).to eq('Invalid client_id')
      end
    end

    context 'when client is not active' do
      it 'returns invalid_client error' do
        controller.params = { redirect_uri: 'https://inactive.com/callback', response_type: 'code' }
        error = controller.send(:validate_client, inactive_client)

        expect(error[:code]).to eq('invalid_client')
        expect(error[:description]).to eq('Client is not active')
      end
    end

    context 'when redirect_uri is invalid' do
      it 'returns invalid_request error' do
        controller.params = { redirect_uri: 'https://malicious.com/callback', response_type: 'code' }
        error = controller.send(:validate_client, client)

        expect(error[:code]).to eq('invalid_request')
        expect(error[:description]).to eq('Invalid redirect_uri')
      end
    end

    context 'when response_type is not supported' do
      it 'returns unsupported_response_type error' do
        controller.params = { redirect_uri: 'https://example.com/callback', response_type: 'token' }
        error = controller.send(:validate_client, client)

        expect(error[:code]).to eq('unsupported_response_type')
        expect(error[:description]).to eq('Client does not support this response_type')
      end
    end

    context 'when all validations pass' do
      it 'returns nil' do
        controller.params = { redirect_uri: 'https://example.com/callback', response_type: 'code' }
        error = controller.send(:validate_client, client)

        expect(error).to be_nil
      end
    end
  end
end
