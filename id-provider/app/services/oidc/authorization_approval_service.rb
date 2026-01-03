# frozen_string_literal: true

module Oidc
  class AuthorizationApprovalService
    def initialize(user, client, authorization_params)
      @user = user
      @client = client
      @authorization_params = authorization_params
    end

    def approve
      authorization_code = generate_authorization_code
      record_consent

      {
        authorization_code: authorization_code,
        redirect_uri: build_approved_redirect_uri(authorization_code),
      }
    end

    def deny
      {
        redirect_uri: build_denied_redirect_uri,
      }
    end

    private

    def generate_authorization_code
      generator = Oidc::AuthorizationCodeGenerator.new(@user, @client, @authorization_params)
      generator.generate
    end

    def record_consent
      requested_scopes = parse_scopes(@authorization_params['scope'])
      UserConsent.record_for(user: @user, client: @client, scopes: requested_scopes)
    end

    def build_approved_redirect_uri(authorization_code)
      presenter = Oidc::RedirectUrlPresenter.new(
        redirect_uri: @authorization_params['redirect_uri'],
        state: @authorization_params['state'],
      )
      presenter.approved(authorization_code.code)
    end

    def build_denied_redirect_uri
      presenter = Oidc::RedirectUrlPresenter.new(
        redirect_uri: @authorization_params['redirect_uri'],
        state: @authorization_params['state'],
      )
      presenter.denied
    end

    def parse_scopes(scope_string)
      return [] if scope_string.blank?

      scope_string.split
    end
  end
end
