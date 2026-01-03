# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Memberships API", type: :request do
  describe "POST /api/roles/:role_id/memberships" do
    it "creates a new membership" do
      # Given
      org = Organization.create!(name: "Test Org", slug: "test-org")
      role = org.roles.create!(name: "Admin", permissions: [ "read", "write" ])
      user_id = SecureRandom.uuid
      params = { membership: { user_id: user_id } }

      # When
      post "/api/roles/#{role.id}/memberships", params: params, as: :json

      # Then
      expect(response).to have_http_status(:created)
      expect(response.content_type).to match(%r{application/json})

      json = JSON.parse(response.body)
      expect(json["user_id"]).to eq(user_id)
      expect(json["role_id"]).to eq(role.id)

      expect(role.role_memberships.find_by(user_id: user_id)).to be_present
    end

    it "returns 422 when validation fails (duplicate membership)" do
      # Given
      org = Organization.create!(name: "Test Org", slug: "test-org")
      role = org.roles.create!(name: "Admin", permissions: [ "read", "write" ])
      user_id = SecureRandom.uuid
      role.role_memberships.create!(user_id: user_id)

      params = { membership: { user_id: user_id } }

      # When
      post "/api/roles/#{role.id}/memberships", params: params, as: :json

      # Then
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.content_type).to match(%r{application/json})

      json = JSON.parse(response.body)
      expect(json["errors"]).to be_present
    end

    it "returns 404 when role not found" do
      # Given
      user_id = SecureRandom.uuid
      params = { membership: { user_id: user_id } }

      # When
      post "/api/roles/00000000-0000-0000-0000-000000000000/memberships", params: params, as: :json

      # Then
      expect(response).to have_http_status(:not_found)
    end
  end
end
