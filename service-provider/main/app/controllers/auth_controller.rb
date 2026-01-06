class AuthController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:logout]
  def login
    state = SecureRandom.hex(16)
    nonce = SecureRandom.hex(16)
    
    session[:oidc_state] = state
    session[:oidc_nonce] = nonce
    
    redirect_to oidc_client.authorization_uri(state: state, nonce: nonce), allow_other_host: true
  end
  
  def callback
    if params[:state] != session[:oidc_state]
      return redirect_to root_url, alert: 'Invalid state parameter'
    end

    if params[:error].present?
      error_message = "Authentication failed: #{params[:error]}"
      error_message += " - #{params[:error_description]}" if params[:error_description].present?
      return redirect_to root_url, alert: error_message
    end

    if params[:code].blank?
      return redirect_to root_url, alert: 'Authentication failed: No authorization code received'
    end

    access_token = oidc_client.authorize!(code: params[:code])
    userinfo = access_token.userinfo!

    # セッションに保存
    session[:access_token] = access_token.access_token
    session[:user_info] = userinfo.raw_attributes

    redirect_to root_url
  end

  def logout
    # セッションをクリア
    session.delete(:access_token)
    session.delete(:user_info)
    session.delete(:oidc_state)
    session.delete(:oidc_nonce)

    # ID Providerのログアウトエンドポイントにリダイレクト
    logout_uri = oidc_client.end_session_uri(
      post_logout_redirect_uri: root_url
    )

    if logout_uri
      redirect_to logout_uri, allow_other_host: true
    else
      redirect_to root_url, notice: 'Successfully logged out'
    end
  end

  private

  def oidc_client
    @oidc_client ||= OidcClient.new
  end
end