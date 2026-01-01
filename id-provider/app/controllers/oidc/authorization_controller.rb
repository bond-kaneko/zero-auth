# app/controllers/oidc/authorization_controller.rb
class Oidc::AuthorizationController < Oidc::ApplicationController
  before_action :validate_authorization_params, only: [:new]
  before_action :find_client, only: [:new]
  before_action :load_client, only: [:create]
  before_action :require_login, only: [:new, :create]

  def new
    # 認可確認画面を表示
    @client = @found_client
    @scopes = parse_scopes(params[:scope])
    @state = params[:state]
    @nonce = params[:nonce]
    @redirect_uri = params[:redirect_uri]
    
    # 認可パラメータをセッションに保存（POST時に使用）
    session[:authorization_params] = {
      client_id: params[:client_id],
      redirect_uri: params[:redirect_uri],
      response_type: params[:response_type],
      scope: params[:scope],
      state: params[:state],
      nonce: params[:nonce],
      code_challenge: params[:code_challenge],
      code_challenge_method: params[:code_challenge_method]
    }
  end

  def create
    if params[:approve] == 'true'
      # デバッグログ
      Rails.logger.info "=== DEBUG: Authorization Code Creation ==="
      Rails.logger.info "scope from session: #{session[:authorization_params]["scope"].inspect}"
      parsed_scopes = parse_scopes(session[:authorization_params]["scope"])
      Rails.logger.info "parsed_scopes: #{parsed_scopes.inspect}"
      Rails.logger.info "redirect_uri: #{session[:authorization_params]["redirect_uri"].inspect}"
      Rails.logger.info "nonce: #{session[:authorization_params]["nonce"].inspect}"
      Rails.logger.info "code_challenge: #{session[:authorization_params]["code_challenge"].inspect}"
      Rails.logger.info "code_challenge_method: #{session[:authorization_params]["code_challenge_method"].inspect}"
      Rails.logger.info "========================================="

      # 認可コードを生成
      authorization_code = AuthorizationCode.create!(
        user: current_user,
        client: @found_client,
        redirect_uri: session[:authorization_params]["redirect_uri"],
        scopes: parsed_scopes,
        nonce: session[:authorization_params]["nonce"],
        code_challenge: session[:authorization_params]["code_challenge"],
        code_challenge_method: session[:authorization_params]["code_challenge_method"]
      )
      
      # リダイレクトURIに認可コードを付与してリダイレクト
      redirect_uri = URI.parse(session[:authorization_params]["redirect_uri"])
      redirect_uri.query = build_query_string(
        code: authorization_code.code,
        state: session[:authorization_params]["state"]
      )
      
      session.delete(:authorization_params)
      redirect_to redirect_uri.to_s, allow_other_host: true
    else
      # ユーザーが拒否した場合
      redirect_uri = URI.parse(session[:authorization_params]["redirect_uri"])
      redirect_uri.query = build_query_string(
        error: 'access_denied',
        error_description: 'The user denied the request',
        state: session[:authorization_params]["state"]
      )
      
      session.delete(:authorization_params)
      redirect_to redirect_uri.to_s, allow_other_host: true
    end
  end

  private

  def validate_authorization_params
    # 必須パラメータのチェック
    if params[:client_id].blank?
      return render_error('invalid_request', 'Missing required parameter: client_id')
    end
    
    if params[:redirect_uri].blank?
      return render_error('invalid_request', 'Missing required parameter: redirect_uri')
    end
    
    if params[:response_type].blank?
      return render_error('invalid_request', 'Missing required parameter: response_type')
    end
    
    # response_typeの検証（現在はcodeのみサポート）
    unless params[:response_type] == 'code'
      return render_error('unsupported_response_type', 'Only "code" response type is supported')
    end
    
    # scopeの検証（openidは必須）
    if params[:scope].blank? || !params[:scope].include?('openid')
      return render_error('invalid_scope', 'The "openid" scope is required')
    end
  end

  def find_client
    @found_client = Client.find_by(client_id: params[:client_id])
    
    unless @found_client
      return render_error('invalid_client', 'Invalid client_id')
    end
    
    unless @found_client.active?
      return render_error('invalid_client', 'Client is not active')
    end
    
    # redirect_uriの検証
    unless @found_client.valid_redirect_uri?(params[:redirect_uri])
      return render_error('invalid_request', 'Invalid redirect_uri')
    end
    
    # response_typeの検証
    unless @found_client.supports_response_type?(params[:response_type])
      return render_error('unsupported_response_type', 'Client does not support this response_type')
    end
  end

  def load_client
    @found_client = Client.find_by(client_id: session.dig(:authorization_params, "client_id"))
    unless @found_client
      render json: { error: 'invalid_request', error_description: 'Session expired' }, status: :bad_request
    end
  end

  def require_login
    unless current_user
      # ログイン後に戻ってくるためのパラメータを保存
      session[:return_to] = request.url
      redirect_to login_url
    end
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def parse_scopes(scope_string)
    return [] if scope_string.blank?
    scope_string.split(' ').compact
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
          state: state || params[:state]
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