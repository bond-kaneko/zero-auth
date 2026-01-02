# frozen_string_literal: true

module Oidc
  class ConfigurationPresenter
    def initialize(issuer:)
      @issuer = issuer
    end

    def to_json(*_args)
      {
        issuer: @issuer,
        authorization_endpoint: "#{@issuer}/oidc/authorize",
        token_endpoint: "#{@issuer}/oidc/token",
        userinfo_endpoint: "#{@issuer}/oidc/userinfo",
        jwks_uri: "#{@issuer}/oidc/jwks",
        end_session_endpoint: "#{@issuer}/oidc/logout",
        response_types_supported: ['code'],
        subject_types_supported: ['public'],
        id_token_signing_alg_values_supported: ['RS256'],
        scopes_supported: %w[openid profile email],
      }
    end
  end
end
