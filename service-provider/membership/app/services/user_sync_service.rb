# frozen_string_literal: true

# Synchronizes user data from id-provider
# - Batch sync via API (sync method)
# - Event-driven sync via messaging (sync_user_created/deleted class methods)
class UserSyncService
  class SyncError < StandardError; end

  def initialize(client: IdProvider::Client.new)
    @client = client
  end

  # Batch sync all users via API
  def sync
    users_data = @client.fetch_all_users

    synced_count = 0
    users_data.each do |user_data|
      user = User.find_or_initialize_by(id_provider_user_id: user_data["sub"])
      user.email = user_data["email"]
      user.name = user_data["name"] || ""
      user.save!
      synced_count += 1
    end

    synced_count
  end

  class << self
    # Create or update user from event payload
    # @param user_id [String] The id_provider user ID
    # @param email [String] User email
    # @param name [String] User name
    # @return [User] The created or updated user
    def sync_user_created(user_id:, email:, name:)
      user = User.find_or_initialize_by(id_provider_user_id: user_id)
      user.email = email
      user.name = name

      if user.save
        Rails.logger.info("User synced via event: #{user_id} (#{email})")
        user
      else
        error_message = "Failed to sync user #{user_id}: #{user.errors.full_messages.join(', ')}"
        Rails.logger.error(error_message)
        raise SyncError, error_message
      end
    end

    # Delete user from event payload
    # @param user_id [String] The id_provider user ID
    # @return [void]
    def sync_user_deleted(user_id:)
      user = User.find_by(id_provider_user_id: user_id)

      if user
        user.destroy!
        Rails.logger.info("User deleted via event: #{user_id}")
      else
        Rails.logger.warn("User not found for deletion: #{user_id}")
      end
    rescue ActiveRecord::RecordNotDestroyed => e
      error_message = "Failed to delete user #{user_id}: #{e.message}"
      Rails.logger.error(error_message)
      raise SyncError, error_message
    end
  end
end
