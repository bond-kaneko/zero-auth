# app/controllers/oidc/user_info_controller.rb
class Oidc::UserInfoController < Oidc::ApplicationController
  def show
    return unless extract_bearer_token
    return unless verify_access_token

    render json: build_userinfo_response
  end

  private

  def extract_bearer_token
    # Authorization: Bearer <token> から取得
    auth_header = request.headers['Authorization']

    unless auth_header&.start_with?('Bearer ')
      return render_error('invalid_token', 'Missing or invalid Authorization header')
    end

    @token_value = auth_header.sub('Bearer ', '').strip

    if @token_value.blank?
      return render_error('invalid_token', 'Missing access token')
    end

    true
  end

  def verify_access_token
    @access_token = AccessToken.find_by(token: @token_value)

    unless @access_token
      return render_error('invalid_token', 'Invalid access token')
    end

    # 有効期限チェック
    if @access_token.expired?
      return render_error('invalid_token', 'Access token has expired')
    end

    true
  end

  def build_userinfo_response
    user = @access_token.user
    scopes = @access_token.scopes || []

    # sub（subject）は必須
    response = {
      sub: user.sub
    }

    # profileスコープ
    if scopes.include?('profile')
      response[:name] = user.name if user.name.present?
      response[:given_name] = user.given_name if user.given_name.present?
      response[:family_name] = user.family_name if user.family_name.present?
      response[:picture] = user.picture if user.picture.present?
    end

    # emailスコープ
    if scopes.include?('email')
      response[:email] = user.email if user.email.present?
      response[:email_verified] = user.email_verified
    end

    response
  end

  def render_error(error_code, error_description)
    render json: {
      error: error_code,
      error_description: error_description
    }, status: :unauthorized
  end
end