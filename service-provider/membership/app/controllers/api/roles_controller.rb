# frozen_string_literal: true

module Api
  class RolesController < ApplicationController
    before_action :set_organization

    def create
      @role = @organization.roles.new(role_params)

      if @role.save
        render json: @role, status: :created
      else
        render json: { errors: @role.errors.full_messages }, status: :unprocessable_content
      end
    end

    private

    def set_organization
      @organization = Organization.find(params[:organization_id])
    end

    def role_params
      params.expect(role: [ :name, { permissions: [] } ])
    end
  end
end
