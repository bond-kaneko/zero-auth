# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
    # ログインフォームを表示
    @return_to = session[:return_to]
  end

  def create
    user = authenticate_user

    if user
      login_user(user)
    else
      handle_authentication_failure
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: 'ログアウトしました'
  end

  private

  def authenticate_user
    user = User.find_by(email: params[:email])
    user if user&.authenticate(params[:password])
  end

  def login_user(user)
    session[:user_id] = user.id
    redirect_path = session.delete(:return_to) || root_path
    redirect_to redirect_path, notice: 'ログインしました'
  end

  def handle_authentication_failure
    flash.now[:alert] = 'メールアドレスまたはパスワードが正しくありません'
    @return_to = session[:return_to]
    render :new, status: :unprocessable_content
  end
end
