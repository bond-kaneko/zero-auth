# frozen_string_literal: true

module Oidc
  class TokenController < Oidc::ApplicationController
    def create
      grant_handler = build_grant_handler
      return render_error_response(grant_handler) if grant_handler.is_a?(Hash)

      validation_error = grant_handler.validate
      return render_error_response(validation_error) if validation_error

      tokens = grant_handler.execute
      render json: build_token_response(tokens)
    end

    private

    def build_grant_handler
      grant_type = params[:grant_type]

      return unsupported_grant_type_error unless Oidc::GrantTypeFactory.supported?(grant_type)

      Oidc::GrantTypeFactory.create(grant_type, params, request)
    end

    def build_token_response(tokens)
      presenter = TokenResponsePresenter.new(tokens)
      presenter = presenter.with_refresh_token if tokens[:refresh_token]
      presenter.to_json
    end

    def unsupported_grant_type_error
      {
        code: 'unsupported_grant_type',
        description: 'Only authorization_code and client_credentials grant types are supported',
      }
    end

    def render_error_response(error)
      render json: {
        error: error[:code],
        error_description: error[:description],
      }, status: :bad_request
    end
  end
end
