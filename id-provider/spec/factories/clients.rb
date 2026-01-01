# frozen_string_literal: true

FactoryBot.define do
  factory :client do
    sequence(:name) { |n| "Client #{n}" }
    sequence(:client_id) { |n| "client-id-#{n}" }
    client_secret { 'client-secret-123' }
    sequence(:redirect_uris) { |n| ["https://example#{n}.com/callback"] }
    response_types { ['code'] }
    grant_types { ['authorization_code'] }
    active { true }

    trait :inactive do
      active { false }
    end
  end
end
