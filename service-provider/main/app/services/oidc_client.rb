class OidcClient
  def initialize
    @discovery = OpenIDConnect::Discovery::Provider::Config.discover!(OIDC_CONFIG[:issuer])
    @client = OpenIDConnect::Client.new(
      identifier: OIDC_CONFIG[:client_id],
      secret: OIDC_CONFIG[:client_secret],
      redirect_uri: OIDC_CONFIG[:redirect_uri],
      authorization_endpoint: @discovery.authorization_endpoint,
      token_endpoint: @discovery.token_endpoint,
      userinfo_endpoint: @discovery.userinfo_endpoint
    )
  end

  def authorization_uri(state:, nonce:)
    @client.authorization_uri(
      state: state,
      nonce: nonce,
      scope: [:openid, :profile, :email]
    )
  end

  def authorize!(code:)
    @client.authorization_code = code
    @client.access_token!
  end

  def end_session_uri(post_logout_redirect_uri:, state: nil)
    endpoint = @discovery.end_session_endpoint
    return nil unless endpoint

    uri = URI.parse(endpoint)
    params = { post_logout_redirect_uri: post_logout_redirect_uri }
    params[:state] = state if state
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end
end