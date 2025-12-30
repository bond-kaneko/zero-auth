OIDC_CONFIG = {
  issuer: ENV.fetch('OIDC_ISSUER', 'http://localhost:3000'),
  client_id: ENV.fetch('OIDC_CLIENT_ID'),
  client_secret: ENV.fetch('OIDC_CLIENT_SECRET'),
  redirect_uri: ENV.fetch('OIDC_REDIRECT_URI', 'http://localhost:3001/auth/callback')
}.freeze