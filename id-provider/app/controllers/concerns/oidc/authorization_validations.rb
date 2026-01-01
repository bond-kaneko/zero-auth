# frozen_string_literal: true

module Oidc
  module AuthorizationValidations
    extend ActiveSupport::Concern

    private

    def validate_required_params
      return render_error('invalid_request', 'Missing required parameter: client_id') if params[:client_id].blank?
      return render_error('invalid_request', 'Missing required parameter: redirect_uri') if params[:redirect_uri].blank?

      if params[:response_type].blank?
        return render_error('invalid_request', 'Missing required parameter: response_type')
      end

      nil
    end

    def validate_response_type
      return nil if params[:response_type] == 'code'

      render_error('unsupported_response_type', 'Only "code" response type is supported')
    end

    def validate_scope
      return nil unless params[:scope].blank? || params[:scope].exclude?('openid')

      render_error('invalid_scope', 'The "openid" scope is required')
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
