# frozen_string_literal: true

require "faraday"

module IdProvider
  class Client
    class Error < StandardError; end

    def initialize(base_url: ENV.fetch("ID_PROVIDER_URL", "https://id-provider.local:3443"))
      @base_url = base_url
      @connection = Faraday.new(url: base_url) do |conn|
        conn.request :json
        conn.response :json
        conn.adapter Faraday.default_adapter
        # Disable SSL verification for local development
        conn.ssl.verify = false if Rails.env.development? || Rails.env.test?
      end
    end

    def fetch_users(page: 1, per_page: 100)
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
      page = 1
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
