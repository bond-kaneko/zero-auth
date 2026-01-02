# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RedirectUrlPresenter do
  let(:redirect_uri) { 'https://example.com/callback' }
  let(:state) { 'random_state_value' }

  describe '#approved' do
    it 'returns redirect URL with authorization code and state' do
      authorization_code = 'test_auth_code_123'

      presenter = described_class.new(redirect_uri: redirect_uri, state: state)
      result = presenter.approved(authorization_code)

      expect(result).to eq('https://example.com/callback?code=test_auth_code_123&state=random_state_value')
    end

    context 'without state' do
      it 'returns redirect URL with authorization code only' do
        authorization_code = 'test_auth_code_456'

        presenter = described_class.new(redirect_uri: redirect_uri, state: nil)
        result = presenter.approved(authorization_code)

        expect(result).to eq('https://example.com/callback?code=test_auth_code_456')
      end
    end
  end

  describe '#denied' do
    it 'returns redirect URL with error and state' do
      presenter = described_class.new(redirect_uri: redirect_uri, state: state)
      result = presenter.denied

      expect(result).to eq(
        'https://example.com/callback?error=access_denied&error_description=The+user+denied+the+request&state=random_state_value',
      )
    end

    context 'without state' do
      it 'returns redirect URL with error only' do
        presenter = described_class.new(redirect_uri: redirect_uri, state: nil)
        result = presenter.denied

        expect(result).to eq(
          'https://example.com/callback?error=access_denied&error_description=The+user+denied+the+request',
        )
      end
    end
  end
end
