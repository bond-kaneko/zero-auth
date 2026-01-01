# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  let(:user) { create(:user, email: 'user@example.com', password: 'Password123') }

  describe 'GET /login' do
    it 'returns success' do
      get login_url

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /login' do
    context 'with valid credentials' do
      it 'logs in the user and redirects to root' do
        post login_url, params: { email: user.email, password: 'Password123' }

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq('ログインしました')
      end
    end

    context 'with invalid email' do
      it 'does not log in and renders new' do
        post login_url, params: { email: 'wrong@example.com', password: 'Password123' }

        expect(response).to have_http_status(:unprocessable_content)
        expect(flash[:alert]).to eq('メールアドレスまたはパスワードが正しくありません')
        expect(session[:user_id]).to be_nil
      end
    end

    context 'with invalid password' do
      it 'does not log in and renders new' do
        post login_url, params: { email: user.email, password: 'WrongPassword' }

        expect(response).to have_http_status(:unprocessable_content)
        expect(flash[:alert]).to eq('メールアドレスまたはパスワードが正しくありません')
        expect(session[:user_id]).to be_nil
      end
    end
  end
end
