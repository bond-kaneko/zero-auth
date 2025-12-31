class AuthController < ApplicationController
  def login
    state = SecureRandom.hex(16)
    nonce = SecureRandom.hex(16)
    
    session[:oidc_state] = state
    session[:oidc_nonce] = nonce
    
    redirect_to oidc_client.authorization_uri(state: state, nonce: nonce), allow_other_host: true
  end
  
  def callback
    if params[:state] != session[:oidc_state]
      return redirect_to root_path, alert: 'Invalid state parameter'
    end

    access_token = oidc_client.authorize!(code: params[:code])
    userinfo = oidc_client.userinfo(access_token: access_token)
    
    # セッションに保存
    session[:access_token] = access_token.access_token
    session[:user_info] = userinfo.raw_attributes
    
    redirect_to root_path
  end

  private

  def oidc_client
    @oidc_client ||= OidcClient.new
  end
end