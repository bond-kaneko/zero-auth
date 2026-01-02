# frozen_string_literal: true

# app/controllers/oidc/token_controller.rb
module Oidc
  class TokenController < Oidc::ApplicationController
    include Oidc::TokenValidation

    def create
      error = validate_token_params || authenticate_client || verify_authorization_code
      return render_error(error[:code], error[:description]) if error

      tokens = generate_tokens

      presenter = TokenResponsePresenter.new(tokens)
      presenter = presenter.with_refresh_token if tokens[:refresh_token]

      render json: presenter.to_json
    end

    private

    def generate_tokens
      generator = Oidc::TokenGenerator.new(@authorization_code, @client)
      generator.generate
    end
  end
end
