# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
    # ログインフォームを表示
    @return_to = session[:return_to]
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_path = session.delete(:return_to) || user_path
      redirect_to redirect_path, notice: 'ログインしました'
    else
      flash.now[:alert] = 'メールアドレスまたはパスワードが正しくありません'
      @return_to = session[:return_to]
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: 'ログアウトしました'
  end
end
