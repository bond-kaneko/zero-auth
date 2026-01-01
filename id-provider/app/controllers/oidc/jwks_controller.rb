# frozen_string_literal: true

# app/controllers/oidc/jwks_controller.rb
module Oidc
  class JwksController < Oidc::ApplicationController
    def index
      # JSON Web Key Set の返却
      render json: { keys: [] }
    end
  end
end
