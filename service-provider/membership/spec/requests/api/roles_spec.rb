# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Roles API", type: :request do
  describe "POST /api/organizations/:organization_id/roles" do
    it "creates a new role" do
      # Given
      org = Organization.create!(name: "Test Org", slug: "test-org")
      params = { role: { name: "Admin", permissions: [ "read", "write" ] } }

      # When
      post "/api/organizations/#{org.id}/roles", params: params, as: :json

      # Then
      expect(response).to have_http_status(:created)
      expect(response.content_type).to match(%r{application/json})

      json = JSON.parse(response.body)
      expect(json["name"]).to eq("Admin")
      expect(json["permissions"]).to eq([ "read", "write" ])
      expect(json["organization_id"]).to eq(org.id)

      expect(org.roles.find_by(name: "Admin")).to be_present
    end

    it "returns 422 when validation fails" do
      # Given
      org = Organization.create!(name: "Test Org", slug: "test-org")
      params = { role: { name: "", permissions: [] } }

      # When
      post "/api/organizations/#{org.id}/roles", params: params, as: :json

      # Then
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.content_type).to match(%r{application/json})

      json = JSON.parse(response.body)
      expect(json["errors"]).to be_present
    end

    it "returns 404 when organization not found" do
      # Given
      params = { role: { name: "Admin", permissions: [ "read" ] } }

      # When
      post "/api/organizations/00000000-0000-0000-0000-000000000000/roles", params: params, as: :json

      # Then
      expect(response).to have_http_status(:not_found)
    end
  end
end
