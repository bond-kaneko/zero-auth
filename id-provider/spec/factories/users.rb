# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { "user-#{SecureRandom.hex(8)}@example.com" }
    password_digest { BCrypt::Password.create('Password123') }
  end
end
