# frozen_string_literal: true

module Api
  class OrganizationsController < ApplicationController
    before_action :set_organization, only: %i[show update destroy]

    def index
      @organizations = Organization.order(created_at: :desc)
      render json: @organizations
    end

    def show
      render json: @organization, include: :roles
    end

    def create
      @organization = Organization.new(organization_params)

      if @organization.save
        render json: @organization, status: :created
      else
        render json: { errors: @organization.errors.full_messages }, status: :unprocessable_content
      end
    end

    def update
      if @organization.update(organization_params)
        render json: @organization
      else
        render json: { errors: @organization.errors.full_messages }, status: :unprocessable_content
      end
    end

    def destroy
      @organization.destroy
      head :no_content
    end

    private

    def set_organization
      @organization = Organization.find(params[:id])
    end

    def organization_params
      params.expect(organization: %i[name slug])
    end
  end
end
