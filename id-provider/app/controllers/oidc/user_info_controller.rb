# frozen_string_literal: true

# app/controllers/oidc/user_info_controller.rb
module Oidc
  class UserInfoController < Oidc::ApplicationController
    include Oidc::BearerTokenValidation

    def show
      error = extract_bearer_token
      return render_error(error[:code], error[:description]) if error

      error = verify_access_token
      return render_error(error[:code], error[:description]) if error

      presenter = UserInfoPresenter.new(@access_token.user, @access_token.scopes)
      render json: presenter.to_oidc_userinfo
    end

    private

    def render_error(error_code, error_description)
      render json: {
        error: error_code,
        error_description: error_description,
      }, status: :unauthorized
    end
  end
end
