# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { "user-#{SecureRandom.hex(8)}@example.com" }
    password { 'Password123' }
  end
end
