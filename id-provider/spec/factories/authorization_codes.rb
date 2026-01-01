# frozen_string_literal: true

FactoryBot.define do
  factory :authorization_code do
    user { nil }
    client { nil }
    sequence(:code) { |n| "auth-code-#{n}" }
    redirect_uri { 'https://example.com/callback' }
    scopes { %w[openid profile email] }
    nonce { 'test-nonce' }
    expires_at { 10.minutes.from_now }
    used { false }

    trait :expired do
      expires_at { 10.minutes.ago }
    end

    trait :used do
      used { true }
    end
  end
end
