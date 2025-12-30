# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  def new
    # ログインフォームを表示
    render plain: "Login page (not implemented)"
  end

  def create
    # ログイン処理
    render json: { error: "not_implemented" }, status: :not_implemented
  end

  def destroy
    # ログアウト処理
    render json: { error: "not_implemented" }, status: :not_implemented
  end
end