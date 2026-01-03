# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserSyncService do
  let(:mock_client) { instance_double(IdProvider::Client) }
  let(:service) { described_class.new(client: mock_client) }

  describe "#sync" do
    context "with new users" do
      let(:mock_users) do
        [
          {
            "id" => 1,
            "sub" => "550e8400-e29b-41d4-a716-446655440001",
            "email" => "user1@example.com",
            "name" => "User 1"
          },
          {
            "id" => 2,
            "sub" => "550e8400-e29b-41d4-a716-446655440002",
            "email" => "user2@example.com",
            "name" => "User 2"
          }
        ]
      end

      it "creates new users" do
        # Given
        allow(mock_client).to receive(:fetch_all_users).and_return(mock_users)
        expect(User.count).to eq(0)

        # When
        result = service.sync

        # Then
        expect(result).to eq(2)
        expect(User.count).to eq(2)

        user1 = User.find_by(id_provider_user_id: "550e8400-e29b-41d4-a716-446655440001")
        expect(user1.email).to eq("user1@example.com")
        expect(user1.name).to eq("User 1")

        user2 = User.find_by(id_provider_user_id: "550e8400-e29b-41d4-a716-446655440002")
        expect(user2.email).to eq("user2@example.com")
        expect(user2.name).to eq("User 2")
      end
    end

    context "with existing users" do
      let(:mock_users) do
        [
          {
            "id" => 1,
            "sub" => "550e8400-e29b-41d4-a716-446655440001",
            "email" => "updated@example.com",
            "name" => "Updated Name"
          }
        ]
      end

      it "updates existing users" do
        # Given
        User.create!(id_provider_user_id: "550e8400-e29b-41d4-a716-446655440001", email: "old@example.com", name: "Old Name")
        allow(mock_client).to receive(:fetch_all_users).and_return(mock_users)

        # When
        result = service.sync

        # Then
        expect(result).to eq(1)
        expect(User.count).to eq(1)

        user = User.find_by(id_provider_user_id: "550e8400-e29b-41d4-a716-446655440001")
        expect(user.email).to eq("updated@example.com")
        expect(user.name).to eq("Updated Name")
      end
    end

    context "with empty name" do
      let(:mock_users) do
        [
          {
            "id" => 1,
            "sub" => "550e8400-e29b-41d4-a716-446655440001",
            "email" => "user1@example.com",
            "name" => nil
          }
        ]
      end

      it "sets empty string for nil name" do
        # Given
        allow(mock_client).to receive(:fetch_all_users).and_return(mock_users)

        # When
        result = service.sync

        # Then
        expect(result).to eq(1)
        user = User.find_by(id_provider_user_id: "550e8400-e29b-41d4-a716-446655440001")
        expect(user.name).to eq("")
      end
    end

    context "with no users" do
      it "returns 0 when no users to sync" do
        # Given
        allow(mock_client).to receive(:fetch_all_users).and_return([])

        # When
        result = service.sync

        # Then
        expect(result).to eq(0)
        expect(User.count).to eq(0)
      end
    end
  end
end
