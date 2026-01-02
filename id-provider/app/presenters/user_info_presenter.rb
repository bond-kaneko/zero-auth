# frozen_string_literal: true

class UserInfoPresenter
  def initialize(user, scopes)
    @user = user
    @scopes = scopes || []
  end

  def to_oidc_userinfo
    response = { sub: @user.sub }
    add_profile_claims(response) if @scopes.include?('profile')
    add_email_claims(response) if @scopes.include?('email')
    response
  end

  private

  def add_profile_claims(response)
    response[:name] = @user.name if @user.name.present?
    response[:given_name] = @user.given_name if @user.given_name.present?
    response[:family_name] = @user.family_name if @user.family_name.present?
    response[:picture] = @user.picture if @user.picture.present?
  end

  def add_email_claims(response)
    response[:email] = @user.email if @user.email.present?
    response[:email_verified] = @user.email_verified
  end
end
