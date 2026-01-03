# frozen_string_literal: true

module IdProvider
  class AuthenticationMiddleware < Faraday::Middleware
    def initialize(app, client:)
      super(app)
      @client = client
    end

    def call(env)
      unless env.url.path == "/oidc/token"
        token = @client.authenticate
        env.request_headers["Authorization"] = "Bearer #{token}"
      end
      @app.call(env)
    end
  end
end
