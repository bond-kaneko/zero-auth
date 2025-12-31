# app/helpers/oidc/authorization_helper.rb
module Oidc::AuthorizationHelper
    def scope_description(scope)
      descriptions = {
        'openid' => 'あなたのID情報にアクセス',
        'profile' => 'プロフィール情報（名前など）にアクセス',
        'email' => 'メールアドレスにアクセス'
      }
      descriptions[scope] || scope
    end
  end