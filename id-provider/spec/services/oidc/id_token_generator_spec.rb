# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Oidc::IdTokenGenerator do
  describe '#generate' do
    it 'generates a valid JWT token' do
      user = create(:user, name: 'John Doe', picture: 'https://example.com/avatar.jpg')
      client = create(:client)
      authorization_code = create(:authorization_code, user: user, client: client, scopes: %w[openid profile email],
                                                       nonce: 'test-nonce')
      generator = described_class.new(user, client, authorization_code)
      secret_key = Rails.application.credentials.dig(:oidc, :jwt_secret) || 'development_secret'

      token = generator.generate
      expect(token).to be_a(String)
      expect { JWT.decode(token, secret_key, true, { algorithm: 'HS256' }) }.not_to raise_error
    end

    it 'includes required claims' do
      user = create(:user, name: 'John Doe', picture: 'https://example.com/avatar.jpg')
      client = create(:client)
      authorization_code = create(:authorization_code, user: user, client: client, scopes: %w[openid profile email],
                                                       nonce: 'test-nonce')
      generator = described_class.new(user, client, authorization_code)
      secret_key = Rails.application.credentials.dig(:oidc, :jwt_secret) || 'development_secret'
      decoded_token = JWT.decode(generator.generate, secret_key, true, { algorithm: 'HS256' })[0]

      expect(decoded_token).to include(
        'iss' => be_present,
        'sub' => user.sub.to_s,
        'aud' => client.client_id,
        'exp' => be_a(Integer),
        'iat' => be_a(Integer),
        'nonce' => 'test-nonce',
      )
    end

    context 'with profile scope' do
      it 'includes name claim when user has name' do
        user = create(:user, name: 'John Doe', picture: 'https://example.com/avatar.jpg')
        client = create(:client)
        authorization_code = create(:authorization_code, user: user, client: client, scopes: %w[openid profile],
                                                         nonce: 'test-nonce')
        generator = described_class.new(user, client, authorization_code)
        secret_key = Rails.application.credentials.dig(:oidc, :jwt_secret) || 'development_secret'
        decoded_token = JWT.decode(generator.generate, secret_key, true, { algorithm: 'HS256' })[0]

        expect(decoded_token['name']).to eq('John Doe')
      end

      it 'includes picture claim when user has picture' do
        user = create(:user, name: 'John Doe', picture: 'https://example.com/avatar.jpg')
        client = create(:client)
        authorization_code = create(:authorization_code, user: user, client: client, scopes: %w[openid profile],
                                                         nonce: 'test-nonce')
        generator = described_class.new(user, client, authorization_code)
        secret_key = Rails.application.credentials.dig(:oidc, :jwt_secret) || 'development_secret'
        decoded_token = JWT.decode(generator.generate, secret_key, true, { algorithm: 'HS256' })[0]

        expect(decoded_token['picture']).to eq('https://example.com/avatar.jpg')
      end

      it 'does not include email claim without email scope' do
        user = create(:user, name: 'John Doe', picture: 'https://example.com/avatar.jpg')
        client = create(:client)
        authorization_code = create(:authorization_code, user: user, client: client, scopes: %w[openid profile],
                                                         nonce: 'test-nonce')
        generator = described_class.new(user, client, authorization_code)
        secret_key = Rails.application.credentials.dig(:oidc, :jwt_secret) || 'development_secret'
        decoded_token = JWT.decode(generator.generate, secret_key, true, { algorithm: 'HS256' })[0]

        expect(decoded_token).not_to have_key('email')
      end

      context 'when user does not have name' do
        it 'does not include name claim' do
          user = create(:user, name: nil)
          client = create(:client)
          authorization_code = create(:authorization_code, user: user, client: client, scopes: %w[openid profile],
                                                           nonce: 'test-nonce')
          generator = described_class.new(user, client, authorization_code)
          secret_key = Rails.application.credentials.dig(:oidc, :jwt_secret) || 'development_secret'
          decoded_token = JWT.decode(generator.generate, secret_key, true, { algorithm: 'HS256' })[0]

          expect(decoded_token).not_to have_key('name')
        end
      end
    end

    context 'with email scope' do
      it 'includes email claim' do
        user = create(:user, name: 'John Doe', picture: 'https://example.com/avatar.jpg')
        client = create(:client)
        authorization_code = create(:authorization_code, user: user, client: client, scopes: %w[openid profile email],
                                                         nonce: 'test-nonce')
        generator = described_class.new(user, client, authorization_code)
        secret_key = Rails.application.credentials.dig(:oidc, :jwt_secret) || 'development_secret'
        decoded_token = JWT.decode(generator.generate, secret_key, true, { algorithm: 'HS256' })[0]

        expect(decoded_token['email']).to eq(user.email)
      end
    end

    context 'without profile scope' do
      it 'does not include profile claims' do
        user = create(:user, name: 'John Doe', picture: 'https://example.com/avatar.jpg')
        client = create(:client)
        authorization_code = create(:authorization_code, user: user, client: client, scopes: %w[openid email],
                                                         nonce: 'test-nonce')
        generator = described_class.new(user, client, authorization_code)
        secret_key = Rails.application.credentials.dig(:oidc, :jwt_secret) || 'development_secret'
        decoded_token = JWT.decode(generator.generate, secret_key, true, { algorithm: 'HS256' })[0]

        expect(decoded_token).not_to have_key('name')
        expect(decoded_token).not_to have_key('picture')
      end

      it 'includes email claim when email scope is present' do
        user = create(:user, name: 'John Doe', picture: 'https://example.com/avatar.jpg')
        client = create(:client)
        authorization_code = create(:authorization_code, user: user, client: client, scopes: %w[openid email],
                                                         nonce: 'test-nonce')
        generator = described_class.new(user, client, authorization_code)
        secret_key = Rails.application.credentials.dig(:oidc, :jwt_secret) || 'development_secret'
        decoded_token = JWT.decode(generator.generate, secret_key, true, { algorithm: 'HS256' })[0]

        expect(decoded_token['email']).to eq(user.email)
      end
    end

    context 'with only openid scope' do
      it 'does not include profile or email claims' do
        user = create(:user, name: 'John Doe', picture: 'https://example.com/avatar.jpg')
        client = create(:client)
        authorization_code = create(:authorization_code, user: user, client: client, scopes: ['openid'],
                                                         nonce: 'test-nonce')
        generator = described_class.new(user, client, authorization_code)
        secret_key = Rails.application.credentials.dig(:oidc, :jwt_secret) || 'development_secret'
        decoded_token = JWT.decode(generator.generate, secret_key, true, { algorithm: 'HS256' })[0]

        expect(decoded_token).not_to have_key('name')
        expect(decoded_token).not_to have_key('picture')
        expect(decoded_token).not_to have_key('email')
      end
    end
  end
end
