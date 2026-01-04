# Service Provider (Main)

OpenID Connect Client（サービスプロバイダー）

## 概要

service-provider (main) は、id-providerと連携するOpenID Connect (OIDC) クライアント実装です。認証が必要なアプリケーションのサンプル実装として、OIDCの認証フローを実装しています。

### 主な機能

- **OIDC認証**: id-providerを使用したOpenID Connect認証フロー
- **セッション管理**: 認証後のセッション管理
- **保護されたリソース**: 認証が必要なページの実装
- **ログアウト**: セッション破棄とログアウト処理

### 技術スタック

- **Backend**: Ruby on Rails 8.1.1
- **Database**: PostgreSQL
- **Authentication**: OpenID Connect (omniauth-openid-connect)

## 起動方法

### 前提条件

- Docker & Docker Compose がインストールされていること
- id-providerが起動していること
- `/etc/hosts` に以下を追加:
  ```
  127.0.0.1 service-provider.local
  ```
- SSL証明書が `../../ssl/` ディレクトリに存在すること

### クライアント登録

まず、id-providerにこのサービスをOIDCクライアントとして登録する必要があります：

1. id-providerの管理画面にアクセス: https://id-provider.local:3443
2. Clients → Create New Client
3. 以下の情報でクライアントを作成:
   - **Name**: Service Provider (Main)
   - **Redirect URI**: `https://service-provider.local:3444/auth/callback`
4. 作成後、`client_id` と `client_secret` をメモ

### 環境変数設定

`.env` ファイルを作成:

```env
RAILS_ENV=development
OIDC_ISSUER=https://id-provider.local:3443
OIDC_CLIENT_ID=your_client_id_here
OIDC_CLIENT_SECRET=your_client_secret_here
OIDC_REDIRECT_URI=https://service-provider.local:3444/auth/callback
```

### コンテナ起動

```bash
# すべてのサービスを起動（DB, Web, Nginx）
docker compose up -d

# ログを確認
docker compose logs -f

# コンテナの状態確認
docker compose ps
```

### 初回セットアップ

```bash
# データベース作成＆マイグレーション
docker compose exec web bin/rails db:create db:migrate
```

### アクセス

- **アプリケーション**: https://service-provider.local:3444

### コンテナの停止

```bash
# すべてのコンテナを停止
docker compose down

# ボリュームも含めて削除
docker compose down -v
```

## 認証フロー

1. ユーザーが `/auth/login` にアクセス
2. id-providerの認証ページにリダイレクト
3. ユーザーがid-providerでログイン
4. `/auth/callback` でコールバックを受け取る
5. ID Tokenを検証してセッション作成
6. 保護されたページにアクセス可能に

## 開発

### Rails Console

```bash
docker compose exec web bin/rails console
```

### テスト実行

```bash
docker compose exec web bin/rails test
```

### RuboCop

```bash
docker compose exec web bundle exec rubocop
```

## アーキテクチャ

### サービス構成

- **db**: PostgreSQLデータベース（ポート5432）
- **web**: Rails アプリケーションサーバー（ポート3001）
- **nginx**: リバースプロキシ（ポート443 → 3444）

### セッション管理

- Railsのセッションストア（cookie-based）を使用
- ID Tokenとユーザー情報をセッションに保存
- ログアウト時にセッションをクリア

## トラブルシューティング

### 認証リダイレクトが失敗する

```bash
# .envファイルの設定を確認
cat .env

# OIDC_ISSUER、OIDC_CLIENT_ID、OIDC_CLIENT_SECRETが正しいか確認
# OIDC_REDIRECT_URIがid-providerに登録されているか確認
```

### データベース接続エラー

```bash
# DBコンテナの状態確認
docker compose ps db

# データベース再作成
docker compose exec web bin/rails db:drop db:create db:migrate
```

### id-providerとの通信エラー

```bash
# id-providerが起動しているか確認
cd ../../id-provider
docker compose ps

# ネットワーク接続確認
docker compose exec web ping id-provider.local
```
