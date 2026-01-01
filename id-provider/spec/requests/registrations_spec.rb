# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registrations', type: :request do
  describe 'GET /signup' do
    it 'returns success' do
      get signup_url

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /signup' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          user: {
            email: 'newuser@example.com',
            password: 'Password123',
            password_confirmation: 'Password123',
          },
        }
      end

      it 'creates a new user' do
        expect do
          post signup_url, params: valid_params
        end.to change(User, :count).by(1)
      end

      it 'logs in the user and redirects to root' do
        post signup_url, params: valid_params

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq('アカウントを作成しました')
      end
    end

    context 'with invalid email' do
      let(:invalid_email_params) do
        {
          user: {
            email: 'invalid-email',
            password: 'Password123',
            password_confirmation: 'Password123',
          },
        }
      end

      it 'does not create a user' do
        expect do
          post signup_url, params: invalid_email_params
        end.not_to change(User, :count)
      end

      it 'returns unprocessable content status' do
        post signup_url, params: invalid_email_params

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'with mismatched password' do
      let(:mismatched_password_params) do
        {
          user: {
            email: 'test@example.com',
            password: 'Password123',
            password_confirmation: 'DifferentPassword',
          },
        }
      end

      it 'does not create a user' do
        expect do
          post signup_url, params: mismatched_password_params
        end.not_to change(User, :count)
      end

      it 'returns unprocessable content status' do
        post signup_url, params: mismatched_password_params

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
