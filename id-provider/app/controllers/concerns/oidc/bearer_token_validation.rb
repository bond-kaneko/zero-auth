# frozen_string_literal: true

module Oidc
  module BearerTokenValidation
    extend ActiveSupport::Concern

    private

    def extract_bearer_token
      auth_header = request.headers['Authorization']

      unless auth_header&.start_with?('Bearer ')
        return { code: 'invalid_token', description: 'Missing or invalid Authorization header' }
      end

      @token_value = auth_header.sub('Bearer ', '').strip

      return { code: 'invalid_token', description: 'Missing access token' } if @token_value.blank?

      nil
    end

    def verify_access_token
      @access_token = AccessToken.find_by(token: @token_value)

      return { code: 'invalid_token', description: 'Invalid access token' } unless @access_token

      return { code: 'invalid_token', description: 'Access token has expired' } if @access_token.expired?

      nil
    end
  end
end
