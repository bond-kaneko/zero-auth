# frozen_string_literal: true

class UserSyncService
  def initialize(client: IdProvider::Client.new)
    @client = client
  end

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
end
