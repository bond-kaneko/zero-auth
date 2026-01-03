# frozen_string_literal: true

module Api
  class UsersController < ApplicationController
    include Paginatable

    rescue_from Paginatable::ValidationError, with: :render_validation_error

    def index
      page = params[:page]&.to_i
      per_page = params[:per_page]&.to_i
      page ||= 0
      per_page ||= 100

      validate_pagination_params!(page: page, per_page: per_page)

      @users = User.order(created_at: :desc)
        .limit(per_page)
        .offset(page * per_page)
      render json: @users
    end

    def sync
      service = UserSyncService.new
      synced_count = service.sync

      render json: { synced_count: synced_count }
    end

    private

    def render_validation_error(exception)
      render json: { errors: [ exception.message ] }, status: :bad_request
    end
  end
end
