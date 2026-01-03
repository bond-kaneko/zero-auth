# frozen_string_literal: true

module Oidc
  module GrantTypes
    class AuthorizationCodeFlow
      def initialize(params, request)
        @params = params
        @request = request
        @client = nil
        @authorization_code = nil
      end

      def validate
        return { code: 'invalid_request', description: 'Missing required parameter: code' } if params[:code].blank?

        if params[:redirect_uri].blank?
          return { code: 'invalid_request', description: 'Missing required parameter: redirect_uri' }
        end

        auth_result = Oidc::ClientAuthenticator.new(params, request).authenticate
        return auth_result[:error] if auth_result[:error]

        @client = auth_result[:client]

        unless @client.grant_types.include?('authorization_code')
          return { code: 'unsupported_grant_type',
                   description: 'Client does not support authorization_code grant type' }
        end

        verify_authorization_code
      end

      def execute
        user = @authorization_code.user

        access_token = create_access_token(user)
        id_token = generate_id_token(user)
        refresh_token = create_refresh_token_if_supported(user)

        @authorization_code.use!

        { access_token: access_token, id_token: id_token, refresh_token: refresh_token }
      end

      private

      attr_reader :params, :request

      def create_access_token(user)
        AccessToken.create!(
          user: user,
          client: @client,
          scopes: @authorization_code.scopes,
          expires_at: 1.hour.from_now,
        )
      end

      def generate_id_token(user)
        IdTokenGenerator.new(user, @client, @authorization_code).generate
      end

      def create_refresh_token_if_supported(user)
        return nil unless @client.grant_types.include?('refresh_token')

        RefreshToken.create!(
          user: user,
          client: @client,
          scopes: @authorization_code.scopes,
          expires_at: 30.days.from_now,
        )
      end

      def verify_authorization_code
        @authorization_code = AuthorizationCode.find_by(code: params[:code])

        return { code: 'invalid_grant', description: 'Invalid authorization code' } unless @authorization_code

        return { code: 'invalid_grant', description: 'Authorization code has expired' } if @authorization_code.expired?

        if @authorization_code.used
          return { code: 'invalid_grant', description: 'Authorization code has already been used' }
        end

        unless @authorization_code.client_id == @client.id
          return { code: 'invalid_grant', description: 'Authorization code was issued to another client' }
        end

        unless @authorization_code.redirect_uri == params[:redirect_uri]
          return { code: 'invalid_grant', description: 'Redirect URI does not match' }
        end

        return verify_pkce_challenge if @authorization_code.code_challenge.present?

        nil
      end

      def verify_pkce_challenge
        code_verifier = params[:code_verifier]

        return { code: 'invalid_request', description: 'Missing code_verifier for PKCE' } if code_verifier.blank?

        computed_challenge = if @authorization_code.code_challenge_method == 'S256'
                               Base64.urlsafe_encode64(
                                 Digest::SHA256.digest(code_verifier),
                                 padding: false,
                               )
                             else
                               code_verifier
                             end

        return nil if computed_challenge == @authorization_code.code_challenge

        { code: 'invalid_grant', description: 'Invalid code_verifier' }
      end
    end
  end
end
