class HomeController < ApplicationController
    def index
      # ログインしていない場合はログインページへリダイレクト
      unless session[:user_info]
        redirect_to auth_login_path
      end
    end
  end