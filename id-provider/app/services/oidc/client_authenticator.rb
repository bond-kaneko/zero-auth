# frozen_string_literal: true

module Oidc
  class ClientAuthenticator
    def initialize(params, request)
      @params = params
      @request = request
    end

    # Authenticate client and return client object
    # Returns { client: Client } or { error: { code: 'error_code', description: 'error_description' } }
    def authenticate
      client_id, client_secret = extract_client_credentials

      client = Client.find_by(client_id: client_id)

      return error('invalid_client', 'Invalid client_id') unless client

      return error('invalid_client', 'Client is not active') unless client.active?

      return error('invalid_client', 'Invalid client_secret') unless client.authenticate(client_secret)

      { client: client }
    end

    private

    attr_reader :params, :request

    def extract_client_credentials
      if request.headers['Authorization']&.start_with?('Basic ')
        credentials = Base64.decode64(request.headers['Authorization'].sub('Basic ', ''))
        credentials.split(':', 2)
      else
        [params[:client_id], params[:client_secret]]
      end
    end

    def error(code, description)
      { error: { code: code, description: description } }
    end
  end
end
