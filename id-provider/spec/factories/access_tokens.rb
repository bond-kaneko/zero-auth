# frozen_string_literal: true

FactoryBot.define do
  factory :access_token do
    user { nil }
    client { nil }
    authorization_code { nil }
    sequence(:token) { |n| "access-token-#{n}" }
    scopes { %w[openid profile email] }
    expires_at { 1.hour.from_now }

    trait :expired do
      expires_at { 1.hour.ago }
    end

    trait :openid_only do
      scopes { %w[openid] }
    end

    trait :with_profile do
      scopes { %w[openid profile] }
    end

    trait :with_email do
      scopes { %w[openid email] }
    end
  end
end
