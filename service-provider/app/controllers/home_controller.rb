class HomeController < ApplicationController
  def index
    # ログインしていない場合はログインページへリダイレクト
    return redirect_to auth_login_url, allow_other_host: true unless session[:user_info]
  end
end