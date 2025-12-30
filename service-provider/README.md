# Service Provider

OpenID Connect Client (サービスプロバイダー)

## セットアップ

詳細はプロジェクトルートの [README.md](../README.md) を参照してください。

### クイックスタート

1. SSL証明書が生成されていることを確認（プロジェクトルートの `ssl/` ディレクトリ）
2. `/etc/hosts` に `service-provider.local` が設定されていることを確認
3. 環境変数ファイル `.env` を作成:

```env
RAILS_ENV=development
OIDC_ISSUER=https://id-provider.local:3443
OIDC_CLIENT_ID=your_client_id
OIDC_CLIENT_SECRET=your_client_secret
OIDC_REDIRECT_URI=https://service-provider.local:3444/auth/callback
```

4. 起動:

```bash
docker compose up
```

5. アクセス: `https://service-provider.local:3444`

## 認証フロー

1. `/auth/login` にアクセス
2. id-providerにリダイレクト
3. 認証後、`/auth/callback` でコールバックを受け取る
