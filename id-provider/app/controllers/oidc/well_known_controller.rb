# app/controllers/oidc/well_known_controller.rb
class Oidc::WellKnownController < Oidc::ApplicationController
  def configuration
    # OpenID Connect Discovery 情報の返却
    render json: {}
  end
end