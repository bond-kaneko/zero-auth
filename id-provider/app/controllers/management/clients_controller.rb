module Management
  class ClientsController < ApplicationController
    before_action :require_login

    def index
      @clients = Client.order(created_at: :desc)
    end
  end
end
