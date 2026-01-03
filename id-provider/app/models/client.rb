# frozen_string_literal: true

class Client < ApplicationRecord
  AUTHORIZATION_CODE = 'authorization_code'
  CLIENT_CREDENTIALS = 'client_credentials'

  has_many :authorization_codes, dependent: :destroy
  has_many :access_tokens, dependent: :destroy
  has_many :refresh_tokens, dependent: :destroy
  has_many :user_consents, dependent: :destroy

  validates :client_id, presence: true, uniqueness: true
  validates :client_secret, presence: true
  validates :client_type, presence: true, inclusion: { in: [AUTHORIZATION_CODE, CLIENT_CREDENTIALS] }
  validates :grant_types, presence: true

  # authorization_code clients require redirect_uris and response_types
  validates :redirect_uris, presence: true, if: :authorization_code_client?
  validates :response_types, presence: true, if: :authorization_code_client?

  before_validation :generate_client_id, on: :create
  before_validation :generate_client_secret, on: :create
  before_validation :set_default_client_type, on: :create

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

  def authorization_code_client?
    client_type == AUTHORIZATION_CODE
  end

  def client_credentials_client?
    client_type == CLIENT_CREDENTIALS
  end

  private

  def generate_client_id
    self.client_id ||= SecureRandom.hex(16)
  end

  def generate_client_secret
    self.client_secret ||= SecureRandom.hex(32)
  end

  def set_default_client_type
    self.client_type ||= AUTHORIZATION_CODE
  end
end
