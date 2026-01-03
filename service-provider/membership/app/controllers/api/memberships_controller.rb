# frozen_string_literal: true

module Api
  class MembershipsController < ApplicationController
    before_action :set_role

    def create
      @membership = @role.role_memberships.new(membership_params)

      if @membership.save
        render json: @membership, status: :created
      else
        render json: { errors: @membership.errors.full_messages }, status: :unprocessable_content
      end
    end

    private

    def set_role
      @role = Role.find(params[:role_id])
    end

    def membership_params
      params.expect(membership: [ :user_id ])
    end
  end
end
