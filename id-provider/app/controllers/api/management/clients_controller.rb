# frozen_string_literal: true

module Api
  module Management
    class ClientsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :set_client, only: %i[show update destroy revoke_secret]

      # GET /api/management/clients
      def index
        @clients = Client.order(created_at: :desc)
        render json: @clients
      end

      # GET /api/management/clients/:id
      def show
        render json: @client
      end

      # POST /api/management/clients
      def create
        @client = Client.new(client_params)
        @client.client_secret = SecureRandom.hex(32)

        if @client.save
          render json: @client, status: :created
        else
          render json: { errors: @client.errors.full_messages }, status: :unprocessable_content
        end
      end

      # PATCH/PUT /api/management/clients/:id
      def update
        if @client.update(client_params)
          render json: @client
        else
          render json: { errors: @client.errors.full_messages }, status: :unprocessable_content
        end
      end

      # DELETE /api/management/clients/:id
      def destroy
        @client.destroy
        head :no_content
      end

      # POST /api/management/clients/:id/revoke_secret
      def revoke_secret
        @client.client_secret = SecureRandom.hex(32)

        if @client.save
          render json: @client
        else
          render json: { errors: @client.errors.full_messages }, status: :unprocessable_content
        end
      end

      private

      def set_client
        @client = Client.find(params[:id])
      end

      def client_params
        params.require(:client).permit(:name, :redirect_uri)
      end
    end
  end
end
