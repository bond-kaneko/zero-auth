# frozen_string_literal: true

module Api
  module Management
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

      def show
        @user = User.find(params[:id])
        render json: @user
      end

      def create
        @user = User.new(user_params)

        if @user.save
          render json: @user, status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_content
        end
      end

      def update
        @user = User.find(params[:id])

        if @user.update(user_params)
          render json: @user
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_content
        end
      end

      def destroy
        @user = User.find(params[:id])
        @user.destroy
        head :no_content
      end

      private

      def render_validation_error(exception)
        render json: { errors: [exception.message] }, status: :bad_request
      end

      def user_params
        params.expect(user: %i[email password name given_name family_name picture email_verified])
      end
    end
  end
end
