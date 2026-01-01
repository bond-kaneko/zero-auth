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

      render json: build_userinfo_response
    end

    private

    def build_userinfo_response
      user = @access_token.user
      scopes = @access_token.scopes || []

      response = { sub: user.sub }

      add_profile_claims(response, user, scopes)
      add_email_claims(response, user, scopes)

      response
    end

    def add_profile_claims(response, user, scopes)
      return unless scopes.include?('profile')

      response[:name] = user.name if user.name.present?
      response[:given_name] = user.given_name if user.given_name.present?
      response[:family_name] = user.family_name if user.family_name.present?
      response[:picture] = user.picture if user.picture.present?
    end

    def add_email_claims(response, user, scopes)
      return unless scopes.include?('email')

      response[:email] = user.email if user.email.present?
      response[:email_verified] = user.email_verified
    end

    def render_error(error_code, error_description)
      render json: {
        error: error_code,
        error_description: error_description,
      }, status: :unauthorized
    end
  end
end
