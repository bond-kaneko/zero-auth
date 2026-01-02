# frozen_string_literal: true

class RedirectUrlPresenter
  def initialize(redirect_uri:, state:)
    @redirect_uri = redirect_uri
    @state = state
  end

  def approved(authorization_code)
    build_url(code: authorization_code, state: @state)
  end

  def denied
    build_url(
      error: 'access_denied',
      error_description: 'The user denied the request',
      state: @state,
    )
  end

  private

  def build_url(params)
    uri = URI.parse(@redirect_uri)
    query_params = params.compact.transform_keys(&:to_s)
    uri.query = URI.encode_www_form(query_params)
    uri.to_s
  end
end
