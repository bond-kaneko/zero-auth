# frozen_string_literal: true

FactoryBot.define do
  factory :user_consent do
    user { nil }
    client { nil }
    scopes { %w[openid profile email] }
    expires_at { nil }

    trait :expired do
      expires_at { 1.day.ago }
    end

    trait :basic_scopes do
      scopes { %w[openid profile] }
    end
  end
end
