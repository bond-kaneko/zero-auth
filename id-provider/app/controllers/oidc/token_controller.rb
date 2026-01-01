# frozen_string_literal: true

# app/controllers/oidc/token_controller.rb
module Oidc
  class TokenController < Oidc::ApplicationController
    include Oidc::TokenValidation

    def create
      error = validate_token_params || authenticate_client || verify_authorization_code
      return render_error(error[:code], error[:description]) if error

      tokens = generate_tokens

      response = {
        access_token: tokens[:access_token].token,
        token_type: 'Bearer',
        expires_in: 3600,
        id_token: tokens[:id_token],
      }

      response[:refresh_token] = tokens[:refresh_token].token if tokens[:refresh_token]

      render json: response
    end

    private

    def generate_tokens
      generator = Oidc::TokenGenerator.new(@authorization_code, @client)
      generator.generate
    end
  end
end
