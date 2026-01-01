# frozen_string_literal: true

module Oidc
  class AuthorizationCodeGenerator
    def initialize(current_user, client, authorization_params)
      @current_user = current_user
      @client = client
      @authorization_params = authorization_params
    end

    def generate
      AuthorizationCode.create!(
        user: @current_user,
        client: @client,
        redirect_uri: @authorization_params['redirect_uri'],
        scopes: parse_scopes(@authorization_params['scope']),
        nonce: @authorization_params['nonce'],
        code_challenge: @authorization_params['code_challenge'],
        code_challenge_method: @authorization_params['code_challenge_method'],
      )
    end

    private

    def parse_scopes(scope_string)
      return [] if scope_string.blank?

      scope_string.split.compact
    end
  end
end
