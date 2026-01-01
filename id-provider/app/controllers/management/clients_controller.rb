module Management
  class ClientsController < ApplicationController
    before_action :require_login
    before_action :set_client, only: [:show, :revoke_secret]

    def index
      @clients = Client.order(created_at: :desc)
    end

    def show
    end

    def revoke_secret
      @client.client_secret = SecureRandom.hex(32)

      if @client.save
        redirect_to management_client_path(@client), notice: 'Client Secretを再生成しました。新しいSecretを必ず保存してください。'
      else
        redirect_to management_client_path(@client), alert: 'Client Secretの再生成に失敗しました'
      end
    end

    private

    def set_client
      @client = Client.find(params[:id])
    end
  end
end
