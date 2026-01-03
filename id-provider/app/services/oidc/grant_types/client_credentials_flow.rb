# frozen_string_literal: true

module Oidc
  module GrantTypes
    class ClientCredentialsFlow
      def initialize(params, request)
        @params = params
        @request = request
        @client = nil
      end

      def validate
        auth_result = Oidc::ClientAuthenticator.new(params, request).authenticate
        return auth_result[:error] if auth_result[:error]

        @client = auth_result[:client]

        unless @client.grant_types.include?('client_credentials')
          return { code: 'unsupported_grant_type',
                   description: 'Client does not support client_credentials grant type' }
        end

        nil
      end

      def execute
        access_token = create_access_token
        scope = params[:scope]

        {
          access_token: access_token,
          id_token: nil,
          refresh_token: nil,
          scope: scope,
        }
      end

      private

      attr_reader :params, :request

      def create_access_token
        AccessToken.create!(
          user: nil,
          client: @client,
          scopes: parse_scopes(params[:scope]),
          expires_at: 1.hour.from_now,
        )
      end

      def parse_scopes(scope_string)
        return [] if scope_string.blank?

        scope_string.split
      end
    end
  end
end
