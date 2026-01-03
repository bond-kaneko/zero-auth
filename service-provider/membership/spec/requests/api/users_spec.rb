# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users API", type: :request do
  describe "POST /api/users/sync" do
    let(:mock_users) do
      [
        {
          "id" => 1,
          "sub" => "550e8400-e29b-41d4-a716-446655440001",
          "email" => "user1@example.com",
          "name" => "User 1",
          "created_at" => "2026-01-01T00:00:00.000Z",
          "updated_at" => "2026-01-01T00:00:00.000Z"
        },
        {
          "id" => 2,
          "sub" => "550e8400-e29b-41d4-a716-446655440002",
          "email" => "user2@example.com",
          "name" => "User 2",
          "created_at" => "2026-01-01T00:00:00.000Z",
          "updated_at" => "2026-01-01T00:00:00.000Z"
        }
      ]
    end

    before do
      # Mock id-provider API client
      allow_any_instance_of(IdProvider::Client).to receive(:fetch_all_users).and_return(mock_users)
    end

    it "syncs users from id-provider" do
      # Given
      expect(User.count).to eq(0)

      # When
      post "/api/users/sync"

      # Then
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to match(%r{application/json})

      json = JSON.parse(response.body)
      expect(json["synced_count"]).to eq(2)
      expect(User.count).to eq(2)

      # Verify user data
      user1 = User.find_by(id_provider_user_id: "550e8400-e29b-41d4-a716-446655440001")
      expect(user1.email).to eq("user1@example.com")
      expect(user1.name).to eq("User 1")

      user2 = User.find_by(id_provider_user_id: "550e8400-e29b-41d4-a716-446655440002")
      expect(user2.email).to eq("user2@example.com")
      expect(user2.name).to eq("User 2")
    end

    it "updates existing users" do
      # Given
      User.create!(id_provider_user_id: "550e8400-e29b-41d4-a716-446655440001", email: "old@example.com", name: "Old Name")

      # When
      post "/api/users/sync"

      # Then
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["synced_count"]).to eq(2)

      # Verify user was updated
      user1 = User.find_by(id_provider_user_id: "550e8400-e29b-41d4-a716-446655440001")
      expect(user1.email).to eq("user1@example.com")
      expect(user1.name).to eq("User 1")
    end
  end

  describe "GET /api/users" do
    before do
      # Create test users
      User.create!(id_provider_user_id: "550e8400-e29b-41d4-a716-446655440001", email: "user1@example.com", name: "User 1")
      User.create!(id_provider_user_id: "550e8400-e29b-41d4-a716-446655440002", email: "user2@example.com", name: "User 2")
      User.create!(id_provider_user_id: "550e8400-e29b-41d4-a716-446655440003", email: "user3@example.com", name: "User 3")
    end

    it "returns all users with default pagination" do
      # When
      get "/api/users"

      # Then
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(3)
    end

    it "returns paginated users" do
      # When
      get "/api/users?page=0&per_page=2"

      # Then
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
    end

    it "searches users by keyword (email match)" do
      # When
      get "/api/users?keyword=user1"

      # Then
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
      expect(json.first["email"]).to eq("user1@example.com")
    end

    it "searches users by keyword (name match)" do
      # When
      get "/api/users?keyword=User 2"

      # Then
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
      expect(json.first["name"]).to eq("User 2")
    end

    it "searches users by keyword (partial match)" do
      # When
      get "/api/users?keyword=@example.com"

      # Then
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(3)
    end

    it "returns empty array when no users match keyword" do
      # When
      get "/api/users?keyword=nonexistent"

      # Then
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to eq([])
    end
  end
end
