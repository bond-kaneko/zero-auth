# app/controllers/oidc/user_info_controller.rb
class Oidc::UserInfoController < Oidc::ApplicationController
  def show
    # ユーザー情報の返却
    render json: { error: "not_implemented" }, status: :not_implemented
  end
end