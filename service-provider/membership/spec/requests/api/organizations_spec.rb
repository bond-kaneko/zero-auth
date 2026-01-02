# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organizations API", type: :request do
  describe "GET /api/organizations" do
    it "returns all organizations" do
      # Given
      org1 = Organization.create!(name: "Org 1", slug: "org-1")
      org2 = Organization.create!(name: "Org 2", slug: "org-2")

      # When
      get "/api/organizations"

      # Then
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to match(%r{application/json})

      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
      expect(json.first["name"]).to eq(org2.name) # 作成順逆順
      expect(json.last["name"]).to eq(org1.name)
    end
  end

  describe "GET /api/organizations/:id" do
    it "returns a single organization" do
      # Given
      org = Organization.create!(name: "Test Org", slug: "test-org")

      # When
      get "/api/organizations/#{org.id}"

      # Then
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to match(%r{application/json})

      json = JSON.parse(response.body)
      expect(json["id"]).to eq(org.id)
      expect(json["name"]).to eq("Test Org")
      expect(json["slug"]).to eq("test-org")
    end

    it "returns 404 when organization not found" do
      # When
      get "/api/organizations/00000000-0000-0000-0000-000000000000"

      # Then
      expect(response).to have_http_status(:not_found)
      expect(response.content_type).to match(%r{application/json})

      json = JSON.parse(response.body)
      expect(json["errors"]).to include("Record not found")
    end
  end

  describe "POST /api/organizations" do
    it "creates a new organization" do
      # Given
      params = { organization: { name: "New Org", slug: "new-org" } }

      # When
      post "/api/organizations", params: params, as: :json

      # Then
      expect(response).to have_http_status(:created)
      expect(response.content_type).to match(%r{application/json})

      json = JSON.parse(response.body)
      expect(json["name"]).to eq("New Org")
      expect(json["slug"]).to eq("new-org")
      expect(Organization.find_by(slug: "new-org")).to be_present
    end

    it "returns 422 when validation fails" do
      # Given
      params = { organization: { name: "", slug: "" } }

      # When
      post "/api/organizations", params: params, as: :json

      # Then
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.content_type).to match(%r{application/json})

      json = JSON.parse(response.body)
      expect(json["errors"]).to be_present
    end
  end

  describe "PATCH /api/organizations/:id" do
    it "updates an organization" do
      # Given
      org = Organization.create!(name: "Old Name", slug: "old-slug")
      params = { organization: { name: "New Name" } }

      # When
      patch "/api/organizations/#{org.id}", params: params, as: :json

      # Then
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to match(%r{application/json})

      json = JSON.parse(response.body)
      expect(json["name"]).to eq("New Name")
      expect(org.reload.name).to eq("New Name")
    end

    it "returns 422 when validation fails" do
      # Given
      org = Organization.create!(name: "Test Org", slug: "test-org")
      params = { organization: { name: "" } }

      # When
      patch "/api/organizations/#{org.id}", params: params, as: :json

      # Then
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.content_type).to match(%r{application/json})

      json = JSON.parse(response.body)
      expect(json["errors"]).to be_present
    end
  end

  describe "DELETE /api/organizations/:id" do
    it "deletes an organization" do
      # Given
      org = Organization.create!(name: "To Delete", slug: "to-delete")

      # When
      delete "/api/organizations/#{org.id}"

      # Then
      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_empty
      expect(Organization.find_by(id: org.id)).to be_nil
    end
  end
end
