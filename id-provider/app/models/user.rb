# frozen_string_literal: true

# app/models/user.rb
# User model for authentication
class User < ApplicationRecord
  has_secure_password

  has_many :authorization_codes, dependent: :destroy
  has_many :access_tokens, dependent: :destroy
  has_many :refresh_tokens, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :sub, presence: true, uniqueness: true

  before_validation :generate_sub, on: :create

  private

  def generate_sub
    self.sub ||= SecureRandom.uuid
  end
end
