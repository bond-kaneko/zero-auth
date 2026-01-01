class RegistrationsController < ApplicationController
    def new
      @user = User.new
      @return_to = session[:return_to]
    end

    def create
      @user = User.new(user_params)

      if @user.save
        sign_in_and_redirect
      else
        flash.now[:alert] = 'アカウントの作成に失敗しました'
        @return_to = session[:return_to]
        render :new, status: :unprocessable_entity
      end
    end

    private

    def sign_in_and_redirect
      session[:user_id] = @user.id
      redirect_path = session.delete(:return_to) || user_path
      redirect_to redirect_path, notice: 'アカウントを作成しました'
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :name)
    end
  end