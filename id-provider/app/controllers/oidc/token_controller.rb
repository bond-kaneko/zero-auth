# frozen_string_literal: true

# app/controllers/oidc/token_controller.rb
module Oidc
  class TokenController < Oidc::ApplicationController
    def create
      error = validate_token_params || authenticate_client || verify_authorization_code
      return render_error(error[:code], error[:description]) if error

      tokens = generate_tokens

      response = {
        access_token: tokens[:access_token].token,
        token_type: 'Bearer',
        expires_in: 3600,
        id_token: tokens[:id_token],
      }

      response[:refresh_token] = tokens[:refresh_token].token if tokens[:refresh_token]

      render json: response
    end

    private

    def validate_token_params
      # grant_typeチェック
      unless params[:grant_type] == 'authorization_code'
        return { code: 'unsupported_grant_type', description: 'Only authorization_code grant type is supported' }
      end

      # 必須パラメータチェック
      return { code: 'invalid_request', description: 'Missing required parameter: code' } if params[:code].blank?

      if params[:redirect_uri].blank?
        return { code: 'invalid_request',
                 description: 'Missing required parameter: redirect_uri' }
      end

      nil
    end

    def render_error(error_code, error_description)
      render json: {
        error: error_code,
        error_description: error_description,
      }, status: :bad_request
    end

    def authenticate_client
      # Basic認証 or POSTパラメータからclient_id/secretを取得
      client_id, client_secret = extract_client_credentials

      @client = Client.find_by(client_id: client_id)

      return { code: 'invalid_client', description: 'Invalid client_id' } unless @client

      return { code: 'invalid_client', description: 'Client is not active' } unless @client.active?

      return { code: 'invalid_client', description: 'Invalid client_secret' } unless @client.authenticate(client_secret)

      nil
    end

    def extract_client_credentials
      # Authorization: Basic base64(client_id:client_secret)
      if request.headers['Authorization']&.start_with?('Basic ')
        credentials = Base64.decode64(request.headers['Authorization'].sub('Basic ', ''))
        credentials.split(':', 2)
      else
        # POSTパラメータから取得
        [params[:client_id], params[:client_secret]]
      end
    end

    def verify_authorization_code
      @authorization_code = AuthorizationCode.find_by(code: params[:code])

      return { code: 'invalid_grant', description: 'Invalid authorization code' } unless @authorization_code

      # 有効期限チェック
      return { code: 'invalid_grant', description: 'Authorization code has expired' } if @authorization_code.expired?

      # 使用済みチェック
      if @authorization_code.used
        return { code: 'invalid_grant',
                 description: 'Authorization code has already been used' }
      end

      # クライアント一致チェック
      unless @authorization_code.client_id == @client.id
        return { code: 'invalid_grant', description: 'Authorization code was issued to another client' }
      end

      # redirect_uri一致チェック
      unless @authorization_code.redirect_uri == params[:redirect_uri]
        return { code: 'invalid_grant', description: 'Redirect URI does not match' }
      end

      # PKCE検証（code_challengeがある場合）
      return verify_pkce_challenge if @authorization_code.code_challenge.present?

      nil
    end

    def verify_pkce_challenge
      code_verifier = params[:code_verifier]

      return { code: 'invalid_request', description: 'Missing code_verifier for PKCE' } if code_verifier.blank?

      # S256の場合: BASE64URL(SHA256(code_verifier))
      computed_challenge = if @authorization_code.code_challenge_method == 'S256'
                             Base64.urlsafe_encode64(
                               Digest::SHA256.digest(code_verifier),
                               padding: false,
                             )
                           else
                             # plainの場合: code_verifier == code_challenge
                             code_verifier
                           end

      return nil if computed_challenge == @authorization_code.code_challenge

      { code: 'invalid_grant', description: 'Invalid code_verifier' }
    end

    def generate_tokens
      generator = Oidc::TokenGenerator.new(@authorization_code, @client)
      generator.generate
    end
  end
end
