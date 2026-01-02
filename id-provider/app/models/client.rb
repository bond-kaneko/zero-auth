# frozen_string_literal: true

class Client < ApplicationRecord
  has_many :authorization_codes, dependent: :destroy
  has_many :access_tokens, dependent: :destroy
  has_many :refresh_tokens, dependent: :destroy
  has_many :user_consents, dependent: :destroy

  validates :client_id, presence: true, uniqueness: true
  validates :client_secret, presence: true
  validates :redirect_uris, presence: true
  validates :grant_types, presence: true
  validates :response_types, presence: true

  before_validation :generate_client_id, on: :create
  before_validation :generate_client_secret, on: :create

  def valid_redirect_uri?(uri)
    redirect_uris.include?(uri)
  end

  def supports_grant_type?(grant_type)
    grant_types.include?(grant_type)
  end

  def supports_response_type?(response_type)
    response_types.include?(response_type)
  end

  def authenticate(secret)
    ActiveSupport::SecurityUtils.secure_compare(client_secret, secret)
  end

  def regenerate_secret
    self.client_secret = SecureRandom.hex(32)
    save
  end

  private

  def generate_client_id
    self.client_id ||= SecureRandom.hex(16)
  end

  def generate_client_secret
    self.client_secret ||= SecureRandom.hex(32)
  end
end
