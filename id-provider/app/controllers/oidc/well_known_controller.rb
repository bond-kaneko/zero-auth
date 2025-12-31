# app/controllers/oidc/well_known_controller.rb
class Oidc::WellKnownController < Oidc::ApplicationController
  def configuration
    issuer = request.base_url.gsub(/\/$/, '')
    
    render json: {
      issuer: issuer,
      authorization_endpoint: "#{issuer}/oidc/authorize",
      token_endpoint: "#{issuer}/oidc/token",
      userinfo_endpoint: "#{issuer}/oidc/userinfo",
      jwks_uri: "#{issuer}/oidc/jwks",
      response_types_supported: ["code"],
      subject_types_supported: ["public"],
      id_token_signing_alg_values_supported: ["RS256"],
      scopes_supported: ["openid", "profile", "email"]
    }
  end
  end
end