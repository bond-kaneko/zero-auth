OIDC_CONFIG = {
  issuer: ENV.fetch('OIDC_ISSUER', 'https://id-provider.local:3443'),
  client_id: ENV.fetch('OIDC_CLIENT_ID'),
  client_secret: ENV.fetch('OIDC_CLIENT_SECRET'),
  redirect_uri: ENV.fetch('OIDC_REDIRECT_URI', 'https://service-provider.local:3444/auth/callback')
}.freeze