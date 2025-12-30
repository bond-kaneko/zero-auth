# app/controllers/oidc/jwks_controller.rb
class Oidc::JwksController < Oidc::ApplicationController
  def index
    # JSON Web Key Set の返却
    render json: { keys: [] }
  end
end