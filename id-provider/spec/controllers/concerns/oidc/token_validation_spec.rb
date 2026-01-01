# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Oidc::TokenValidation do
  let(:test_controller_class) do
    Class.new(ApplicationController) do
      include Oidc::TokenValidation

      attr_accessor :params, :request

      def initialize
        super
        @params = {}
        @request = Struct.new(:headers).new({})
      end
    end
  end

  let(:controller) { test_controller_class.new }
  let(:client) { create(:client) }
  let(:inactive_client) { create(:client, :inactive) }
  let(:user) { create(:user) }

  describe '#validate_token_params' do
    context 'when grant_type is not authorization_code' do
      it 'returns unsupported_grant_type error' do
        controller.params = {
          grant_type: 'refresh_token',
          code: 'test-code',
          redirect_uri: 'https://example.com/callback',
        }

        error = controller.send(:validate_token_params)

        expect(error[:code]).to eq('unsupported_grant_type')
        expect(error[:description]).to include('authorization_code')
      end
    end

    context 'when code is missing' do
      it 'returns invalid_request error' do
        controller.params = {
          grant_type: 'authorization_code',
          redirect_uri: 'https://example.com/callback',
        }

        error = controller.send(:validate_token_params)

        expect(error[:code]).to eq('invalid_request')
        expect(error[:description]).to include('code')
      end
    end

    context 'when redirect_uri is missing' do
      it 'returns invalid_request error' do
        controller.params = {
          grant_type: 'authorization_code',
          code: 'test-code',
        }

        error = controller.send(:validate_token_params)

        expect(error[:code]).to eq('invalid_request')
        expect(error[:description]).to include('redirect_uri')
      end
    end

    context 'when all required params are present' do
      it 'returns nil' do
        controller.params = {
          grant_type: 'authorization_code',
          code: 'test-code',
          redirect_uri: 'https://example.com/callback',
        }

        error = controller.send(:validate_token_params)

        expect(error).to be_nil
      end
    end
  end

  describe '#extract_client_credentials' do
    context 'with Basic auth header' do
      it 'extracts credentials' do
        credentials = Base64.strict_encode64("#{client.client_id}:#{client.client_secret}")
        controller.request.headers['Authorization'] = "Basic #{credentials}"

        client_id, client_secret = controller.send(:extract_client_credentials)

        expect(client_id).to eq(client.client_id)
        expect(client_secret).to eq(client.client_secret)
      end
    end

    context 'with POST params' do
      it 'extracts credentials' do
        controller.params = {
          client_id: client.client_id,
          client_secret: client.client_secret,
        }

        client_id, client_secret = controller.send(:extract_client_credentials)

        expect(client_id).to eq(client.client_id)
        expect(client_secret).to eq(client.client_secret)
      end
    end
  end

  describe '#authenticate_client' do
    context 'when client_id is invalid' do
      it 'returns invalid_client error' do
        controller.params = {
          client_id: 'invalid-client-id',
          client_secret: 'some-secret',
        }

        error = controller.send(:authenticate_client)

        expect(error[:code]).to eq('invalid_client')
        expect(error[:description]).to include('client_id')
      end
    end

    context 'when client is not active' do
      it 'returns invalid_client error' do
        controller.params = {
          client_id: inactive_client.client_id,
          client_secret: inactive_client.client_secret,
        }

        error = controller.send(:authenticate_client)

        expect(error[:code]).to eq('invalid_client')
        expect(error[:description]).to include('not active')
      end
    end

    context 'when client_secret is invalid' do
      it 'returns invalid_client error' do
        controller.params = {
          client_id: client.client_id,
          client_secret: 'invalid-secret',
        }

        error = controller.send(:authenticate_client)

        expect(error[:code]).to eq('invalid_client')
        expect(error[:description]).to include('client_secret')
      end
    end

    context 'when credentials are valid' do
      it 'returns nil' do
        controller.params = {
          client_id: client.client_id,
          client_secret: client.client_secret,
        }

        error = controller.send(:authenticate_client)

        expect(error).to be_nil
      end
    end
  end

  describe '#verify_authorization_code' do
    before do
      controller.instance_variable_set(:@client, client)
    end

    context 'when code does not exist' do
      it 'returns invalid_grant error' do
        controller.params = { code: 'non-existent-code', redirect_uri: 'https://example.com/callback' }

        error = controller.send(:verify_authorization_code)

        expect(error[:code]).to eq('invalid_grant')
        expect(error[:description]).to include('Invalid authorization code')
      end
    end

    context 'when code has expired' do
      it 'returns invalid_grant error' do
        expired_code = create(:authorization_code, :expired, user: user, client: client)
        controller.params = { code: expired_code.code, redirect_uri: expired_code.redirect_uri }

        error = controller.send(:verify_authorization_code)

        expect(error[:code]).to eq('invalid_grant')
        expect(error[:description]).to include('expired')
      end
    end

    context 'when code has already been used' do
      it 'returns invalid_grant error' do
        used_code = create(:authorization_code, :used, user: user, client: client)
        controller.params = { code: used_code.code, redirect_uri: used_code.redirect_uri }

        error = controller.send(:verify_authorization_code)

        expect(error[:code]).to eq('invalid_grant')
        expect(error[:description]).to include('already been used')
      end
    end

    context 'when redirect_uri does not match' do
      it 'returns invalid_grant error' do
        valid_code = create(:authorization_code, user: user, client: client)
        controller.params = { code: valid_code.code, redirect_uri: 'https://different.com/callback' }

        error = controller.send(:verify_authorization_code)

        expect(error[:code]).to eq('invalid_grant')
        expect(error[:description]).to include('Redirect URI does not match')
      end
    end

    context 'when code is valid' do
      it 'returns nil' do
        valid_code = create(:authorization_code, user: user, client: client)
        controller.params = { code: valid_code.code, redirect_uri: valid_code.redirect_uri }

        error = controller.send(:verify_authorization_code)

        expect(error).to be_nil
      end
    end
  end
end
