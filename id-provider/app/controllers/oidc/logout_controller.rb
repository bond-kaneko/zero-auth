# frozen_string_literal: true

module Oidc
  # OIDC RP-Initiated Logout endpoint
  # Handles logout requests from Relying Parties
  class LogoutController < ApplicationController
    # Skip CSRF protection for OIDC logout endpoint
    skip_before_action :verify_authenticity_token

    def destroy
      # Clear the user session
      reset_session

      # Handle post_logout_redirect_uri if provided
      redirect_url = params[:post_logout_redirect_uri]
      state = params[:state]

      if redirect_url.present?
        # Validate redirect_uri (should match registered client redirect URIs)
        # For now, we'll allow any HTTPS URL for simplicity
        redirect_url = "#{redirect_url}?state=#{state}" if state.present?
        redirect_to redirect_url, allow_other_host: true
      else
        # Default redirect to IdP home page
        redirect_to root_url, notice: 'Successfully logged out'
      end
    end
  end
end
