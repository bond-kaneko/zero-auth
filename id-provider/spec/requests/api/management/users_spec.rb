# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users Management API', type: :request do
  describe 'GET /api/management/users' do
    context 'without pagination parameters' do
      it 'returns all users with default pagination' do
        # Given
        create_list(:user, 5)

        # When
        get '/api/management/users'

        # Then
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(%r{application/json})

        json = JSON.parse(response.body)
        expect(json.length).to eq(5)
      end
    end

    context 'with valid pagination parameters' do
      it 'returns paginated results' do
        # Given
        create_list(:user, 10)

        # When
        get '/api/management/users', params: { page: 1, per_page: 3 }

        # Then
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.length).to eq(3)
      end

      it 'returns second page of results' do
        # Given
        create_list(:user, 5)

        # When
        get '/api/management/users', params: { page: 2, per_page: 2 }

        # Then
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.length).to eq(2)
      end

      it 'returns empty array when page exceeds total pages' do
        # Given
        create_list(:user, 3)

        # When
        get '/api/management/users', params: { page: 10, per_page: 10 }

        # Then
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.length).to eq(0)
      end
    end

    context 'with ordering' do
      it 'returns users ordered by created_at desc' do
        # Given
        user1 = create(:user, created_at: 1.day.ago)
        create(:user, created_at: 1.hour.ago)
        user3 = create(:user, created_at: 1.minute.ago)

        # When
        get '/api/management/users'

        # Then
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.first['sub']).to eq(user3.sub)
        expect(json.last['sub']).to eq(user1.sub)
      end
    end
  end
end
