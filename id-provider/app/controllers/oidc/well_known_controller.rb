# frozen_string_literal: true

# app/controllers/oidc/well_known_controller.rb
module Oidc
  class WellKnownController < Oidc::ApplicationController
    def configuration
      issuer = ENV.fetch('OIDC_ISSUER', 'https://id-provider.local:3443')
      presenter = OidcConfigurationPresenter.new(issuer: issuer)
      render json: presenter.to_json
    end
  end
end
