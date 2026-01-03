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
    it "returns a single organization with roles" do
      # Given
      org = Organization.create!(name: "Test Org", slug: "test-org")
      role1 = org.roles.create!(name: "Admin", permissions: [ "read", "write" ])
      role2 = org.roles.create!(name: "Member", permissions: [ "read" ])

      # When
      get "/api/organizations/#{org.id}"

      # Then
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to match(%r{application/json})

      json = JSON.parse(response.body)
      expect(json["id"]).to eq(org.id)
      expect(json["name"]).to eq("Test Org")
      expect(json["slug"]).to eq("test-org")

      # Check roles are included
      expect(json["roles"]).to be_an(Array)
      expect(json["roles"].length).to eq(2)

      admin_role = json["roles"].find { |r| r["name"] == "Admin" }
      expect(admin_role).to be_present
      expect(admin_role["permissions"]).to eq([ "read", "write" ])
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

  describe "GET /api/organizations/:id/memberships" do
    it "returns all memberships for the organization with role information" do
      # Given
      org = Organization.create!(name: "Test Org", slug: "test-org")
      admin_role = org.roles.create!(name: "Admin", permissions: [ "read", "write" ])
      member_role = org.roles.create!(name: "Member", permissions: [ "read" ])

      user1_id = SecureRandom.uuid
      user2_id = SecureRandom.uuid
      User.create!(id_provider_user_id: user1_id, email: "user1@example.com", name: "User 1")
      User.create!(id_provider_user_id: user2_id, email: "user2@example.com", name: "User 2")

      membership1 = admin_role.role_memberships.create!(user_id: user1_id)
      membership2 = member_role.role_memberships.create!(user_id: user1_id)
      membership3 = member_role.role_memberships.create!(user_id: user2_id)

      # When
      get "/api/organizations/#{org.id}/memberships"

      # Then
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to match(%r{application/json})

      json = JSON.parse(response.body)
      expect(json.length).to eq(3)

      # Check membership1 (user1 - Admin role)
      m1 = json.find { |m| m["id"] == membership1.id }
      expect(m1).to be_present
      expect(m1["user_id"]).to eq(user1_id)
      expect(m1["role_id"]).to eq(admin_role.id)
      expect(m1["role"]).to be_present
      expect(m1["role"]["name"]).to eq("Admin")
      expect(m1["role"]["permissions"]).to eq([ "read", "write" ])

      # Check membership2 (user1 - Member role)
      m2 = json.find { |m| m["id"] == membership2.id }
      expect(m2).to be_present
      expect(m2["user_id"]).to eq(user1_id)
      expect(m2["role_id"]).to eq(member_role.id)
      expect(m2["role"]).to be_present
      expect(m2["role"]["name"]).to eq("Member")
      expect(m2["role"]["permissions"]).to eq([ "read" ])

      # Check membership3 (user2 - Member role)
      m3 = json.find { |m| m["id"] == membership3.id }
      expect(m3).to be_present
      expect(m3["user_id"]).to eq(user2_id)
      expect(m3["role_id"]).to eq(member_role.id)
      expect(m3["role"]).to be_present
      expect(m3["role"]["name"]).to eq("Member")
      expect(m3["role"]["permissions"]).to eq([ "read" ])
    end

    it "returns empty array when organization has no memberships" do
      # Given
      org = Organization.create!(name: "Empty Org", slug: "empty-org")

      # When
      get "/api/organizations/#{org.id}/memberships"

      # Then
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to eq([])
    end

    it "returns 404 when organization not found" do
      # When
      get "/api/organizations/00000000-0000-0000-0000-000000000000/memberships"

      # Then
      expect(response).to have_http_status(:not_found)
    end

    it "searches memberships by keyword (user email)" do
      # Given
      org = Organization.create!(name: "Test Org", slug: "test-org")
      role = org.roles.create!(name: "Admin", permissions: [ "read" ])

      user1 = User.create!(id_provider_user_id: "user-1", email: "alice@example.com", name: "Alice")
      user2 = User.create!(id_provider_user_id: "user-2", email: "bob@example.com", name: "Bob")

      role.role_memberships.create!(user_id: user1.id_provider_user_id)
      role.role_memberships.create!(user_id: user2.id_provider_user_id)

      # When
      get "/api/organizations/#{org.id}/memberships?keyword=alice"

      # Then
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
      expect(json.first["user_id"]).to eq("user-1")
    end

    it "searches memberships by keyword (role name)" do
      # Given
      org = Organization.create!(name: "Test Org", slug: "test-org")
      admin_role = org.roles.create!(name: "Admin", permissions: [ "read" ])
      member_role = org.roles.create!(name: "Member", permissions: [ "read" ])

      user1 = User.create!(id_provider_user_id: "user-1", email: "alice@example.com", name: "Alice")

      admin_role.role_memberships.create!(user_id: user1.id_provider_user_id)
      member_role.role_memberships.create!(user_id: user1.id_provider_user_id)

      # When
      get "/api/organizations/#{org.id}/memberships?keyword=Admin"

      # Then
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
      expect(json.first["role"]["name"]).to eq("Admin")
    end
  end
end
