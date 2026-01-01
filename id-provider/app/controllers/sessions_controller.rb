class SessionsController < ApplicationController
  def new
    # ログインフォームを表示
    @return_to = session[:return_to]
  end

  def create
    user = User.find_by(email: params[:email])
    
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to = session.delete(:return_to) || root_path
      redirect_to redirect_to, notice: 'ログインしました'
    else
      flash.now[:alert] = 'メールアドレスまたはパスワードが正しくありません'
      @return_to = session[:return_to]
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: 'ログアウトしました'
  end
end