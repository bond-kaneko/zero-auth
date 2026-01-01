# app/controllers/oidc/token_controller.rb
class Oidc::TokenController < Oidc::ApplicationController
  def create
    return unless validate_token_params
    return unless authenticate_client
    return unless verify_authorization_code

    tokens = generate_tokens

    response = {
      access_token: tokens[:access_token].token,
      token_type: 'Bearer',
      expires_in: 3600,
      id_token: tokens[:id_token]
    }

    if tokens[:refresh_token]
      response[:refresh_token] = tokens[:refresh_token].token
    end

    render json: response
  end

  private

  def validate_token_params
    # grant_typeチェック
    unless params[:grant_type] == 'authorization_code'
      return render_error('unsupported_grant_type', 'Only authorization_code grant type is supported')
    end

    # 必須パラメータチェック
    if params[:code].blank?
      return render_error('invalid_request', 'Missing required parameter: code')
    end

    if params[:redirect_uri].blank?
      return render_error('invalid_request', 'Missing required parameter: redirect_uri')
    end

    true
  end

  def render_error(error_code, error_description)
    render json: {
      error: error_code,
      error_description: error_description
    }, status: :bad_request
  end

  def authenticate_client
    # Basic認証 or POSTパラメータからclient_id/secretを取得
    client_id, client_secret = extract_client_credentials

    @client = Client.find_by(client_id: client_id)

    unless @client
      return render_error('invalid_client', 'Invalid client_id')
    end

    unless @client.active?
      return render_error('invalid_client', 'Client is not active')
    end

    unless @client.authenticate(client_secret)
      return render_error('invalid_client', 'Invalid client_secret')
    end

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

    unless @authorization_code
      return render_error('invalid_grant', 'Invalid authorization code')
    end

    # 有効期限チェック
    if @authorization_code.expired?
      return render_error('invalid_grant', 'Authorization code has expired')
    end

    # 使用済みチェック
    if @authorization_code.used
      return render_error('invalid_grant', 'Authorization code has already been used')
    end

    # クライアント一致チェック
    unless @authorization_code.client_id == @client.id
      return render_error('invalid_grant', 'Authorization code was issued to another client')
    end

    # redirect_uri一致チェック
    unless @authorization_code.redirect_uri == params[:redirect_uri]
      return render_error('invalid_grant', 'Redirect URI does not match')
    end

    # PKCE検証（code_challengeがある場合）
    if @authorization_code.code_challenge.present?
      verify_pkce_challenge
    end

    true
  end

  def verify_pkce_challenge
    code_verifier = params[:code_verifier]

    unless code_verifier.present?
      return render_error('invalid_request', 'Missing code_verifier for PKCE')
    end

    # S256の場合: BASE64URL(SHA256(code_verifier))
    if @authorization_code.code_challenge_method == 'S256'
      computed_challenge = Base64.urlsafe_encode64(
        Digest::SHA256.digest(code_verifier),
        padding: false
      )
    else
      # plainの場合: code_verifier == code_challenge
      computed_challenge = code_verifier
    end

    unless computed_challenge == @authorization_code.code_challenge
      return render_error('invalid_grant', 'Invalid code_verifier')
    end
  end

  def generate_tokens
    user = @authorization_code.user

    # アクセストークン生成
    access_token = AccessToken.create!(
      user: user,
      client: @client,
      scopes: @authorization_code.scopes,
      expires_at: 1.hour.from_now
    )

    # IDトークン生成（OIDC）
    id_token = generate_id_token(user, @client, @authorization_code.nonce)

    # リフレッシュトークン生成（オプション）
    refresh_token = nil
    if @client.grant_types.include?('refresh_token')
      refresh_token = RefreshToken.create!(
        user: user,
        client: @client,
        scopes: @authorization_code.scopes,
        expires_at: 30.days.from_now
      )
    end

    # 認可コードを使用済みにマーク
    @authorization_code.use!

    {
      access_token: access_token,
      id_token: id_token,
      refresh_token: refresh_token
    }
  end

  def generate_id_token(user, client, nonce)
    # JWTペイロード
    payload = {
      iss: Rails.application.config.action_controller.default_url_options[:host] || request.base_url,
      sub: user.sub,  # ユーザーの一意識別子
      aud: client.client_id,
      exp: 1.hour.from_now.to_i,
      iat: Time.current.to_i,
      nonce: nonce
    }

    # scopeに応じてクレームを追加
    if @authorization_code.scopes.include?('profile')
      payload[:name] = user.name if user.respond_to?(:name)
      payload[:email] = user.email if @authorization_code.scopes.include?('email')
    end

    # JWT署名（HS256使用）
    # 本番環境では環境変数から秘密鍵を取得
    secret_key = Rails.application.credentials.dig(:oidc, :jwt_secret) || 'development_secret'
    JWT.encode(payload, secret_key, 'HS256')
  end

end