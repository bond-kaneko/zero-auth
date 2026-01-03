# frozen_string_literal: true

# app/models/user.rb
# User model for authentication
class User < ApplicationRecord
  has_secure_password

  has_many :authorization_codes, dependent: :destroy
  has_many :access_tokens, dependent: :destroy
  has_many :refresh_tokens, dependent: :destroy
  has_many :user_consents, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :sub, presence: true, uniqueness: true

  before_validation :generate_sub, on: :create

  # Publish events after transaction commits
  after_commit :publish_user_created_event, on: :create
  after_commit :publish_user_deleted_event, on: :destroy

  private

  def generate_sub
    self.sub ||= SecureRandom.uuid
  end

  def publish_user_created_event
    Events::EventPublisher.current.publish(
      event_type: 'user.created',
      payload: {
        user_id: sub,
        email: email,
        name: name,
      },
    )
  rescue Events::EventPublisher::PublishError => e
    Rails.logger.error("Failed to publish user.created event for user #{sub}: #{e.message}")
    # Don't raise - event publish failure shouldn't fail user creation
  end

  def publish_user_deleted_event
    Events::EventPublisher.current.publish(
      event_type: 'user.deleted',
      payload: {
        user_id: sub,
      },
    )
  rescue Events::EventPublisher::PublishError => e
    Rails.logger.error("Failed to publish user.deleted event for user #{sub}: #{e.message}")
    # Don't raise - event publish failure shouldn't fail user deletion
  end
end
