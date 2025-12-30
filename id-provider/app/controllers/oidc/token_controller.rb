# app/controllers/oidc/token_controller.rb
class Oidc::TokenController < Oidc::ApplicationController
  def create
    # アクセストークン・IDトークン・リフレッシュトークンの発行
    render json: { error: "not_implemented" }, status: :not_implemented
  end
end