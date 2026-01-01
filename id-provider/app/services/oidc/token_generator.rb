# frozen_string_literal: true

module Oidc
  class TokenGenerator
    def initialize(authorization_code, client)
      @authorization_code = authorization_code
      @client = client
    end

    def generate
      user = @authorization_code.user

      access_token = create_access_token(user)
      id_token = IdTokenGenerator.new(user, @client, @authorization_code).generate
      refresh_token = create_refresh_token_if_supported(user)

      @authorization_code.use!

      { access_token: access_token, id_token: id_token, refresh_token: refresh_token }
    end

    private

    def create_access_token(user)
      AccessToken.create!(
        user: user,
        client: @client,
        scopes: @authorization_code.scopes,
        expires_at: 1.hour.from_now,
      )
    end

    def create_refresh_token_if_supported(user)
      return nil unless @client.grant_types.include?('refresh_token')

      RefreshToken.create!(
        user: user,
        client: @client,
        scopes: @authorization_code.scopes,
        expires_at: 30.days.from_now,
      )
    end
  end
end
