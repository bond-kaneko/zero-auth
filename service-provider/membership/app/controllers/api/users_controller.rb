# frozen_string_literal: true

module Api
  class UsersController < ApplicationController
    def sync
      service = UserSyncService.new
      synced_count = service.sync

      render json: { synced_count: synced_count }
    end
  end
end
