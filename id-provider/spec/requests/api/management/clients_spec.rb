# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Management Clients', type: :request do
  let(:client) { create(:client, name: 'Test Client') }

  describe 'GET /api/management/clients' do
    it 'returns all clients ordered by created_at desc' do
      create(:client, name: 'Older Client')
      create(:client, name: 'Newer Client')

      get api_management_clients_path

      expect(response).to have_http_status(:success)
      json = response.parsed_body
      expect(json.size).to eq(2)
      expect(json.first['name']).to eq('Newer Client')
      expect(json.second['name']).to eq('Older Client')
    end
  end

  describe 'GET /api/management/clients/:id' do
    it 'returns the specified client' do
      get api_management_client_path(client)

      expect(response).to have_http_status(:success)
      json = response.parsed_body
      expect(json).to include(
        'id' => client.id,
        'name' => 'Test Client',
      )
    end
  end

  describe 'POST /api/management/clients' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          client: {
            name: 'New Client',
            redirect_uris: ['https://newclient.com/callback'],
            grant_types: ['authorization_code'],
            response_types: ['code'],
          },
        }
      end

      it 'creates a new client with generated secret' do
        expect do
          post api_management_clients_path, params: valid_params
        end.to change(Client, :count).by(1)

        expect(response).to have_http_status(:created)
        json = response.parsed_body
        expect(json).to include(
          'name' => 'New Client',
          'redirect_uris' => ['https://newclient.com/callback'],
          'grant_types' => ['authorization_code'],
          'response_types' => ['code'],
        )
        expect(json['client_secret']).to be_present
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          client: {
            name: '',
            redirect_uris: [],
          },
        }
      end

      it 'returns unprocessable_content with errors' do
        expect do
          post api_management_clients_path, params: invalid_params
        end.not_to change(Client, :count)

        expect(response).to have_http_status(:unprocessable_content)
        json = response.parsed_body
        expect(json).to have_key('errors')
      end
    end
  end

  describe 'PATCH /api/management/clients/:id' do
    context 'with valid parameters' do
      let(:update_params) do
        {
          client: {
            name: 'Updated Client',
          },
        }
      end

      it 'updates the client' do
        patch api_management_client_path(client), params: update_params

        expect(response).to have_http_status(:success)
        json = response.parsed_body
        expect(json['name']).to eq('Updated Client')
      end
    end
  end

  describe 'DELETE /api/management/clients/:id' do
    it 'deletes the client' do
      client_to_delete = create(:client)

      expect do
        delete api_management_client_path(client_to_delete)
      end.to change(Client, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'POST /api/management/clients/:id/revoke_secret' do
    it 'regenerates the client secret' do
      old_secret = client.client_secret

      post revoke_secret_api_management_client_path(client)

      expect(response).to have_http_status(:success)
      json = response.parsed_body
      expect(json['client_secret']).not_to eq(old_secret)
      expect(json['client_secret']).to be_present
    end
  end
end
