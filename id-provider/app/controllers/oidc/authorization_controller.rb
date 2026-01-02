# frozen_string_literal: true

module Oidc
  class AuthorizationController < Oidc::ApplicationController
    include Oidc::RequestValidation
    include Oidc::ClientValidations

    before_action :check_authorization_params, only: [:new]
    before_action :find_client, only: [:new]
    before_action :load_client, only: [:create]
    before_action :require_login, only: %i[new create]

    def new
      requested_scopes = parse_scopes(params[:scope])
      existing_consent = current_user.user_consents.valid.find_by(client: @found_client)
      if existing_consent&.covers_scopes?(requested_scopes)
        auto_approve_authorization
      else
        show_consent_screen(requested_scopes)
      end
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

    def destroy
      reset_session

      redirect_url = params[:post_logout_redirect_uri]
      state = params[:state]

      if redirect_url.present?
        redirect_url = "#{redirect_url}?state=#{state}" if state.present?
        redirect_to redirect_url, allow_other_host: true
      else
        redirect_to root_url, notice: 'Successfully logged out'
      end
    end

    private

    def check_authorization_params
      error = validate_required_params || validate_response_type || validate_scope
      render_error(error[:code], error[:description]) if error
    end

    def find_client
      @found_client = Client.find_by(client_id: params[:client_id])
      error = validate_client(@found_client)
      render_error(error[:code], error[:description]) if error
    end

    def load_client
      @found_client = Client.find_by(client_id: session.dig(:authorization_params, 'client_id'))
      return if @found_client

      render json: { error: 'invalid_request', error_description: 'Session expired' }, status: :bad_request
    end

    def save_authorization_params_to_session
      session[:authorization_params] = {
        'client_id' => params[:client_id],
        'redirect_uri' => params[:redirect_uri],
        'response_type' => params[:response_type],
        'scope' => params[:scope],
        'state' => params[:state],
        'nonce' => params[:nonce],
        'code_challenge' => params[:code_challenge],
        'code_challenge_method' => params[:code_challenge_method],
      }
    end

    def handle_authorization_approval
      generator = Oidc::AuthorizationCodeGenerator.new(
        current_user,
        @found_client,
        session[:authorization_params],
      )
      authorization_code = generator.generate
      record_user_consent

      redirect_url_presenter = RedirectUrlPresenter.new(
        redirect_uri: session[:authorization_params]['redirect_uri'],
        state: session[:authorization_params]['state'],
      )
      redirect_url_presenter.approved(authorization_code.code)
    end

    def handle_authorization_denial
      redirect_url_presenter = RedirectUrlPresenter.new(
        redirect_uri: session[:authorization_params]['redirect_uri'],
        state: session[:authorization_params]['state'],
      )
      redirect_url_presenter.denied
    end

    def record_user_consent
      requested_scopes = parse_scopes(session[:authorization_params]['scope'])
      consent = current_user.user_consents.find_or_initialize_by(client: @found_client)
      consent.scopes = requested_scopes
      consent.expires_at = nil
      consent.save!
    end

    def auto_approve_authorization
      save_authorization_params_to_session
      generator = Oidc::AuthorizationCodeGenerator.new(current_user, @found_client, session[:authorization_params])
      authorization_code = generator.generate

      redirect_url_presenter = RedirectUrlPresenter.new(
        redirect_uri: session[:authorization_params]['redirect_uri'],
        state: session[:authorization_params]['state'],
      )
      redirect_uri = redirect_url_presenter.approved(authorization_code.code)

      session.delete(:authorization_params)
      redirect_to redirect_uri, allow_other_host: true
    end

    def show_consent_screen(requested_scopes)
      @client = @found_client
      @scopes = requested_scopes
      @state = params[:state]
      @nonce = params[:nonce]
      @redirect_uri = params[:redirect_uri]
      save_authorization_params_to_session
    end
  end
end
