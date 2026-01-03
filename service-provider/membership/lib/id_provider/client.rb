# frozen_string_literal: true

require "faraday"
require_relative "authentication_middleware"

module IdProvider
  class Client
    class Error < StandardError; end

    def initialize(
      base_url: ENV.fetch("ID_PROVIDER_URL", "https://id-provider.local:3443"),
      client_id: ENV.fetch("ID_PROVIDER_CLIENT_ID", nil),
      client_secret: ENV.fetch("ID_PROVIDER_CLIENT_SECRET", nil)
    )
      @base_url = base_url
      @client_id = client_id
      @client_secret = client_secret
      @access_token = nil
      @connection = Faraday.new(url: base_url) do |conn|
        conn.request :json
        conn.use AuthenticationMiddleware, client: self
        conn.response :json
        conn.adapter Faraday.default_adapter
        # Disable SSL verification for local development
        conn.ssl.verify = false if Rails.env.development? || Rails.env.test?
      end
    end

    def authenticate
      return @access_token if @access_token

      credentials = Base64.strict_encode64("#{@client_id}:#{@client_secret}")

      response = @connection.post("/oidc/token") do |req|
        req.headers["Authorization"] = "Basic #{credentials}"
        req.body = { grant_type: "client_credentials" }
      end

      unless response.success?
        raise Error, "Authentication failed: #{response.status} - #{response.body}"
      end

      @access_token = response.body["access_token"]
    rescue Faraday::Error => e
      raise Error, "Network error during authentication: #{e.message}"
    end

    def fetch_users(page: 0, per_page: 100)
      response = @connection.get("/api/management/users") do |req|
        req.params["page"] = page
        req.params["per_page"] = per_page
      end

      raise Error, "Failed to fetch users: #{response.status}" unless response.success?

      response.body
    rescue Faraday::Error => e
      raise Error, "Network error: #{e.message}"
    end

    def fetch_all_users
      all_users = []
      page = 0
      per_page = 100

      loop do
        users = fetch_users(page: page, per_page: per_page)
        break if users.empty?

        all_users.concat(users)
        page += 1
      end

      all_users
    end
  end
end
