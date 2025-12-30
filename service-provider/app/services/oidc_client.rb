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
  
    def userinfo(access_token:)
      @client.userinfo!(access_token: access_token)
    end
  end