# frozen_string_literal: true

require "rails_helper"

RSpec.describe IdProvider::Client do
  let(:client) { described_class.new(base_url: "https://id-provider.local:3443") }
  let(:connection) { instance_double(Faraday::Connection) }
  let(:response) { instance_double(Faraday::Response) }

  before do
    allow(Faraday).to receive(:new).and_return(connection)
  end

  describe "#fetch_users" do
    let(:users_data) do
      [
        { "sub" => "user-1", "email" => "user1@example.com", "name" => "User 1" },
        { "sub" => "user-2", "email" => "user2@example.com", "name" => "User 2" }
      ]
    end

    it "fetches users with default pagination (page 0)" do
      expect(connection).to receive(:get).with("/api/management/users") do |&block|
        req = double("request")
        allow(req).to receive(:params).and_return({})
        block.call(req)
        expect(req.params["page"]).to eq(0)
        expect(req.params["per_page"]).to eq(100)
      end.and_return(response)

      allow(response).to receive(:success?).and_return(true)
      allow(response).to receive(:body).and_return(users_data)

      result = client.fetch_users

      expect(result).to eq(users_data)
    end

    it "fetches users with custom pagination" do
      expect(connection).to receive(:get).with("/api/management/users") do |&block|
        req = double("request")
        allow(req).to receive(:params).and_return({})
        block.call(req)
        expect(req.params["page"]).to eq(2)
        expect(req.params["per_page"]).to eq(50)
      end.and_return(response)

      allow(response).to receive(:success?).and_return(true)
      allow(response).to receive(:body).and_return(users_data)

      result = client.fetch_users(page: 2, per_page: 50)

      expect(result).to eq(users_data)
    end

    it "raises error when response is not successful" do
      allow(connection).to receive(:get).and_return(response)
      allow(response).to receive(:success?).and_return(false)
      allow(response).to receive(:status).and_return(500)

      expect do
        client.fetch_users
      end.to raise_error(IdProvider::Client::Error, "Failed to fetch users: 500")
    end

    it "raises error on network failure" do
      allow(connection).to receive(:get).and_raise(Faraday::ConnectionFailed.new("Connection failed"))

      expect do
        client.fetch_users
      end.to raise_error(IdProvider::Client::Error, /Network error/)
    end
  end

  describe "#fetch_all_users" do
    it "fetches all users across multiple pages" do
      page1_data = [
        { "sub" => "user-1", "email" => "user1@example.com", "name" => "User 1" },
        { "sub" => "user-2", "email" => "user2@example.com", "name" => "User 2" }
      ]
      page2_data = [
        { "sub" => "user-3", "email" => "user3@example.com", "name" => "User 3" }
      ]

      response1 = instance_double(Faraday::Response)
      response2 = instance_double(Faraday::Response)
      response3 = instance_double(Faraday::Response)

      # First page (page 0)
      expect(connection).to receive(:get).with("/api/management/users").ordered do |&block|
        req = double("request")
        allow(req).to receive(:params).and_return({})
        block.call(req)
        expect(req.params["page"]).to eq(0)
      end.and_return(response1)
      allow(response1).to receive(:success?).and_return(true)
      allow(response1).to receive(:body).and_return(page1_data)

      # Second page (page 1)
      expect(connection).to receive(:get).with("/api/management/users").ordered do |&block|
        req = double("request")
        allow(req).to receive(:params).and_return({})
        block.call(req)
        expect(req.params["page"]).to eq(1)
      end.and_return(response2)
      allow(response2).to receive(:success?).and_return(true)
      allow(response2).to receive(:body).and_return(page2_data)

      # Third page (page 2) - empty
      expect(connection).to receive(:get).with("/api/management/users").ordered do |&block|
        req = double("request")
        allow(req).to receive(:params).and_return({})
        block.call(req)
        expect(req.params["page"]).to eq(2)
      end.and_return(response3)
      allow(response3).to receive(:success?).and_return(true)
      allow(response3).to receive(:body).and_return([])

      result = client.fetch_all_users

      expect(result).to eq(page1_data + page2_data)
    end

    it "returns empty array when no users exist" do
      allow(connection).to receive(:get).and_return(response)
      allow(response).to receive(:success?).and_return(true)
      allow(response).to receive(:body).and_return([])

      result = client.fetch_all_users

      expect(result).to eq([])
    end
  end
end
