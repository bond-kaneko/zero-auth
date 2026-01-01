# frozen_string_literal: true

# app/controllers/oidc/authorization_controller.rb
module Oidc
  class AuthorizationController < Oidc::ApplicationController
    include Oidc::AuthorizationValidations

    before_action :validate_authorization_params, only: [:new]
    before_action :find_client, only: [:new]
    before_action :load_client, only: [:create]
    before_action :require_login, only: %i[new create]

    def new
      # 認可確認画面を表示
      @client = @found_client
      @scopes = parse_scopes(params[:scope])
      @state = params[:state]
      @nonce = params[:nonce]
      @redirect_uri = params[:redirect_uri]

      save_authorization_params_to_session
    end

    def create
      redirect_uri = if params[:approve] == 'true'
                       handle_authorization_approval
                     else
                       handle_authorization_denial
                     end

      session.delete(:authorization_params)
      redirect_to redirect_uri.to_s, allow_other_host: true
    end

    private

    def validate_authorization_params
      validate_required_params || validate_response_type || validate_scope
    end

    def find_client
      @found_client = Client.find_by(client_id: params[:client_id])

      return render_error('invalid_client', 'Invalid client_id') unless @found_client

      return render_error('invalid_client', 'Client is not active') unless @found_client.active?

      # redirect_uriの検証
      unless @found_client.valid_redirect_uri?(params[:redirect_uri])
        return render_error('invalid_request', 'Invalid redirect_uri')
      end

      # response_typeの検証
      return if @found_client.supports_response_type?(params[:response_type])

      render_error('unsupported_response_type', 'Client does not support this response_type')
    end

    def load_client
      @found_client = Client.find_by(client_id: session.dig(:authorization_params, 'client_id'))
      return if @found_client

      render json: { error: 'invalid_request', error_description: 'Session expired' }, status: :bad_request
    end

    def require_login
      return if current_user

      # ログイン後に戻ってくるためのパラメータを保存
      session[:return_to] = request.url
      redirect_to login_url
    end

    def current_user
      @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end

    def save_authorization_params_to_session
      session[:authorization_params] = {
        client_id: params[:client_id],
        redirect_uri: params[:redirect_uri],
        response_type: params[:response_type],
        scope: params[:scope],
        state: params[:state],
        nonce: params[:nonce],
        code_challenge: params[:code_challenge],
        code_challenge_method: params[:code_challenge_method],
      }
    end

    def handle_authorization_approval
      generator = Oidc::AuthorizationCodeGenerator.new(
        current_user,
        @found_client,
        session[:authorization_params],
      )
      authorization_code = generator.generate

      build_approval_redirect_uri(authorization_code)
    end

    def build_approval_redirect_uri(authorization_code)
      redirect_uri = URI.parse(session[:authorization_params]['redirect_uri'])
      redirect_uri.query = build_query_string(
        code: authorization_code.code,
        state: session[:authorization_params]['state'],
      )
      redirect_uri
    end

    def handle_authorization_denial
      redirect_uri = URI.parse(session[:authorization_params]['redirect_uri'])
      redirect_uri.query = build_query_string(
        error: 'access_denied',
        error_description: 'The user denied the request',
        state: session[:authorization_params]['state'],
      )
      redirect_uri
    end
  end
end
