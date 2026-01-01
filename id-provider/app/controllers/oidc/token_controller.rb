# frozen_string_literal: true

# app/controllers/oidc/token_controller.rb
module Oidc
  class TokenController < Oidc::ApplicationController
    def create
      return unless validate_token_params
      return unless authenticate_client
      return unless verify_authorization_code

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
        return render_error('unsupported_grant_type', 'Only authorization_code grant type is supported')
      end

      # 必須パラメータチェック
      return render_error('invalid_request', 'Missing required parameter: code') if params[:code].blank?

      return render_error('invalid_request', 'Missing required parameter: redirect_uri') if params[:redirect_uri].blank?

      true
    end

    def render_error(error_code, error_description)
      render json: {
        error: error_code,
        error_description: error_description,
      }, status: :bad_request
      false
    end

    def authenticate_client
      # Basic認証 or POSTパラメータからclient_id/secretを取得
      client_id, client_secret = extract_client_credentials

      @client = Client.find_by(client_id: client_id)

      return render_error('invalid_client', 'Invalid client_id') unless @client

      return render_error('invalid_client', 'Client is not active') unless @client.active?

      return render_error('invalid_client', 'Invalid client_secret') unless @client.authenticate(client_secret)

      true
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

      return render_error('invalid_grant', 'Invalid authorization code') unless @authorization_code

      # 有効期限チェック
      return render_error('invalid_grant', 'Authorization code has expired') if @authorization_code.expired?

      # 使用済みチェック
      return render_error('invalid_grant', 'Authorization code has already been used') if @authorization_code.used

      # クライアント一致チェック
      unless @authorization_code.client_id == @client.id
        return render_error('invalid_grant', 'Authorization code was issued to another client')
      end

      # redirect_uri一致チェック
      unless @authorization_code.redirect_uri == params[:redirect_uri]
        return render_error('invalid_grant', 'Redirect URI does not match')
      end

      # PKCE検証（code_challengeがある場合）
      return verify_pkce_challenge if @authorization_code.code_challenge.present?

      true
    end

    def verify_pkce_challenge
      code_verifier = params[:code_verifier]

      return render_error('invalid_request', 'Missing code_verifier for PKCE') if code_verifier.blank?

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

      return true if computed_challenge == @authorization_code.code_challenge

      return render_error('invalid_grant', 'Invalid code_verifier')
    end

    def generate_tokens
      generator = Oidc::TokenGenerator.new(@authorization_code, @client)
      generator.generate
    end
  end
end
