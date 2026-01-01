# frozen_string_literal: true

module Oidc
  module AuthorizationValidations
    extend ActiveSupport::Concern

    private

    def validate_required_params
      if params[:client_id].blank?
        return { code: 'invalid_request', description: 'Missing required parameter: client_id' }
      end
      if params[:redirect_uri].blank?
        return { code: 'invalid_request', description: 'Missing required parameter: redirect_uri' }
      end
      if params[:response_type].blank?
        return { code: 'invalid_request', description: 'Missing required parameter: response_type' }
      end

      nil
    end

    def validate_response_type
      return nil if params[:response_type] == 'code'

      { code: 'unsupported_response_type', description: 'Only "code" response type is supported' }
    end

    def validate_scope
      return nil unless params[:scope].blank? || params[:scope].exclude?('openid')

      { code: 'invalid_scope', description: 'The "openid" scope is required' }
    end

    def validate_client(client)
      return { code: 'invalid_client', description: 'Invalid client_id' } unless client
      return { code: 'invalid_client', description: 'Client is not active' } unless client.active?
      unless client.valid_redirect_uri?(params[:redirect_uri])
        return { code: 'invalid_request', description: 'Invalid redirect_uri' }
      end
      return nil if client.supports_response_type?(params[:response_type])

      { code: 'unsupported_response_type', description: 'Client does not support this response_type' }
    end

    def parse_scopes(scope_string)
      return [] if scope_string.blank?

      scope_string.split.compact
    end

    def build_query_string(params_hash)
      params_hash.compact.map { |k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join('&')
    end

    def render_error(error_code, error_description, state = nil)
      if params[:redirect_uri].present?
        begin
          redirect_uri = URI.parse(params[:redirect_uri])
          redirect_uri.query = build_query_string(
            error: error_code,
            error_description: error_description,
            state: state || params[:state],
          )
          redirect_to redirect_uri.to_s, allow_other_host: true
        rescue URI::InvalidURIError
          render json: { error: error_code, error_description: error_description }, status: :bad_request
        end
      else
        render json: { error: error_code, error_description: error_description }, status: :bad_request
      end
    end
  end
end
