# frozen_string_literal: true

module Oidc
  module RequestValidation
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
      if params[:response_type] != 'code'
        return { code: 'unsupported_response_type', description: 'Only "code" response type is supported' }
      end

      nil
    end

    def validate_scope
      if params[:scope].blank? || params[:scope].exclude?('openid')
        return { code: 'invalid_scope', description: 'The "openid" scope is required' }
      end

      nil
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
