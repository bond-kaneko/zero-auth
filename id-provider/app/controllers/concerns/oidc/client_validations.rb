# frozen_string_literal: true

module Oidc
  module ClientValidations
    extend ActiveSupport::Concern

    private

    def validate_client(client)
      return { code: 'invalid_client', description: 'Invalid client_id' } unless client
      return { code: 'invalid_client', description: 'Client is not active' } unless client.active?
      unless client.valid_redirect_uri?(params[:redirect_uri])
        return { code: 'invalid_request', description: 'Invalid redirect_uri' }
      end
      unless client.supports_response_type?(params[:response_type])
        return { code: 'unsupported_response_type', description: 'Client does not support this response_type' }
      end

      nil
    end
  end
end
