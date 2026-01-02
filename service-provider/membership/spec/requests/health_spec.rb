# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Health endpoint", type: :request do
  describe "GET /health" do
    it "returns ok status with service name" do
      get "/health"

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to match(%r{application/json})

      json_response = JSON.parse(response.body)
      expect(json_response).to eq({
        "status" => "ok",
        "service" => "membership"
      })
    end
  end
end
