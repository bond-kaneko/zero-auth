# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserInfoPresenter do
  let(:user) { create(:user) }

  describe '#to_oidc_userinfo' do
    context 'with openid scope only' do
      it 'returns only sub claim' do
        presenter = described_class.new(user, ['openid'])

        result = presenter.to_oidc_userinfo

        expect(result).to eq({ sub: user.sub })
      end
    end

    context 'with profile scope' do
      let(:user_with_profile) do
        create(:user, name: 'John Doe', given_name: 'John', family_name: 'Doe', picture: 'https://example.com/avatar.jpg')
      end

      it 'returns sub and profile claims' do
        presenter = described_class.new(user_with_profile, %w[openid profile])

        result = presenter.to_oidc_userinfo

        expect(result).to include(
          sub: user_with_profile.sub,
          name: 'John Doe',
          given_name: 'John',
          family_name: 'Doe',
          picture: 'https://example.com/avatar.jpg',
        )
        expect(result).not_to have_key(:email)
      end
    end

    context 'with email scope' do
      it 'returns sub and email claims' do
        presenter = described_class.new(user, %w[openid email])

        result = presenter.to_oidc_userinfo

        expect(result).to include(
          sub: user.sub,
          email: user.email,
          email_verified: user.email_verified,
        )
        expect(result).not_to have_key(:name)
      end
    end

    context 'with all scopes' do
      let(:user_with_all) do
        create(:user, name: 'Jane Smith', email: 'jane@example.com', email_verified: true)
      end

      it 'returns all available claims' do
        presenter = described_class.new(user_with_all, %w[openid profile email])

        result = presenter.to_oidc_userinfo

        expect(result).to include(
          sub: user_with_all.sub,
          email: 'jane@example.com',
          email_verified: true,
          name: 'Jane Smith',
        )
      end
    end
  end
end
