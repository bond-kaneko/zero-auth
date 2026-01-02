# frozen_string_literal: true

module Oidc
  class TokenResponsePresenter
    def initialize(tokens)
      @tokens = tokens
      @response = {
        access_token: tokens[:access_token].token,
        token_type: 'Bearer',
        expires_in: 3600,
        id_token: tokens[:id_token],
      }
    end

    def with_refresh_token
      @response[:refresh_token] = @tokens[:refresh_token].token
      self
    end

    def to_json(*_args)
      @response
    end
  end
end
