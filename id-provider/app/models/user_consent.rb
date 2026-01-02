# frozen_string_literal: true

class UserConsent < ApplicationRecord
  belongs_to :user
  belongs_to :client

  serialize :scopes, type: Array, coder: JSON

  validates :user_id, uniqueness: { scope: :client_id }

  scope :valid, -> { where('expires_at IS NULL OR expires_at > ?', Time.current) }
  scope :expired, -> { where.not(expires_at: nil).where(expires_at: ..Time.current) }

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def covers_scopes?(requested_scopes)
    requested_scopes.all? { |scope| scopes.include?(scope) }
  end

  def self.record_for(user:, client:, scopes:)
    consent = user.user_consents.find_or_initialize_by(client: client)
    consent.scopes = scopes
    consent.expires_at = nil
    consent.save!
    consent
  end
end
