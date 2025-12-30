# app/controllers/oidc/authorization_controller.rb
class Oidc::AuthorizationController < Oidc::ApplicationController
  def new
    # 認可リクエストの表示（ログインフォーム or 認可確認画面）
    render plain: "Authorization endpoint (not implemented)"
  end

  def create
    # 認可コードの発行
    render json: { error: "not_implemented" }, status: :not_implemented
  end
end