# frozen_string_literal: true

module Oidc
  class IdTokenGenerator
    def initialize(user, client, authorization_code)
      @user = user
      @client = client
      @authorization_code = authorization_code
    end

    def generate
      payload = build_payload
      add_claims_to_payload(payload)
      encode_jwt(payload)
    end

    private

    def build_payload
      {
        iss: issuer_url,
        sub: @user.sub,
        aud: @client.client_id,
        exp: 1.hour.from_now.to_i,
        iat: Time.current.to_i,
        nonce: @authorization_code.nonce,
      }
    end

    def issuer_url
      ENV.fetch('OIDC_ISSUER', 'http://localhost:3000')
    end

    def add_claims_to_payload(payload)
      return unless @authorization_code.scopes.include?('profile')

      payload[:name] = @user.name if @user.respond_to?(:name)
      payload[:email] = @user.email if @authorization_code.scopes.include?('email')
    end

    def encode_jwt(payload)
      secret_key = Rails.application.credentials.dig(:oidc, :jwt_secret) || 'development_secret'
      JWT.encode(payload, secret_key, 'HS256')
    end
  end
end
