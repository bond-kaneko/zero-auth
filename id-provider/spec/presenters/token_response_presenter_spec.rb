# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokenResponsePresenter do
  describe '#to_json' do
    let(:access_token) { instance_double(AccessToken, token: 'access_token_value') }
    let(:id_token) { 'id_token_jwt_value' }

    context 'without refresh_token' do
      it 'returns token response without refresh_token' do
        tokens = {
          access_token: access_token,
          id_token: id_token,
        }

        result = described_class.new(tokens).to_json

        expect(result).to eq(
          {
            access_token: 'access_token_value',
            token_type: 'Bearer',
            expires_in: 3600,
            id_token: 'id_token_jwt_value',
          },
        )
        expect(result).not_to have_key(:refresh_token)
      end
    end

    context 'with refresh_token' do
      let(:refresh_token) { instance_double(RefreshToken, token: 'refresh_token_value') }

      it 'returns token response with refresh_token using method chain' do
        tokens = {
          access_token: access_token,
          id_token: id_token,
          refresh_token: refresh_token,
        }

        result = described_class.new(tokens).with_refresh_token.to_json

        expect(result).to eq(
          {
            access_token: 'access_token_value',
            token_type: 'Bearer',
            expires_in: 3600,
            id_token: 'id_token_jwt_value',
            refresh_token: 'refresh_token_value',
          },
        )
      end
    end
  end
end
