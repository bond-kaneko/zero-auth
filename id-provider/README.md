# ID Provider

OpenID Connect Provider（認証サーバー）

## 概要

id-providerは、OpenID Connect (OIDC) プロトコルに準拠した認証サーバーです。ユーザー認証、クライアント管理、トークン発行などの機能を提供します。

### 主な機能

- **ユーザー認証**: メールアドレス/パスワードによるユーザー認証
- **クライアント管理**: OIDCクライアント（サービスプロバイダー）の登録・管理
- **トークン発行**: ID Token、Access Tokenの発行
- **イベント発行**: ユーザー作成・削除イベントをKafkaに発行
- **管理API**: ユーザー・クライアント管理用のREST API

### 技術スタック

- **Backend**: Ruby on Rails 8.1.1
- **Database**: PostgreSQL
- **Message Broker**: Apache Kafka + Zookeeper
- **Frontend**: React 19 + Vite + TypeScript

## 起動方法

### 前提条件

- Docker & Docker Compose がインストールされていること
- `/etc/hosts` に以下を追加:
  ```
  127.0.0.1 id-provider.local
  ```
- SSL証明書が `../ssl/` ディレクトリに存在すること（プロジェクトルートで `mkcert` を使用して生成）

### 環境変数設定

`.env` ファイルを作成（必要に応じて）:

```env
RAILS_ENV=development
DATABASE_URL=postgres://postgres:postgres@db:5432/id_provider_development
KAFKA_BROKERS=kafka:9092
```

### コンテナ起動

```bash
# すべてのサービスを起動（Kafka, Zookeeper, DB, Web, Frontend, Nginx）
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

# サンプルデータ投入（オプション）
docker compose exec web bin/rails db:seed
```

### アクセス

- **フロントエンド**: https://id-provider.local:3443
- **API**: https://id-provider.local:3443/api
- **管理API**: https://id-provider.local:3443/api/management

### コンテナの停止

```bash
# すべてのコンテナを停止
docker compose down

# ボリュームも含めて削除
docker compose down -v
```

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

### データベースリセット

```bash
docker compose exec web bin/rails db:reset
```

## アーキテクチャ

### サービス構成

- **zookeeper**: Kafka用の分散調整サービス（ポート2181）
- **kafka**: メッセージブローカー（ポート9092: 内部, 9093: 外部）
- **db**: PostgreSQLデータベース（ポート5432）
- **web**: Rails APIサーバー（ポート3000）
- **frontend**: React開発サーバー（ポート5173）
- **nginx**: リバースプロキシ（ポート443 → 3443）

### イベント駆動アーキテクチャ

ユーザーの作成・削除時に、Kafkaの `user-events` トピックにイベントを発行します。

**イベントペイロード例**:
```json
{
  "event_type": "user.created",
  "event_id": "uuid-here",
  "timestamp": "2026-01-04T07:46:16Z",
  "version": "1.0",
  "payload": {
    "user_id": "user-uuid",
    "email": "user@example.com",
    "name": "User Name"
  }
}
```

## API仕様

### Management API

#### ユーザー管理

- `GET /api/management/users` - ユーザー一覧取得
- `GET /api/management/users/:id` - ユーザー詳細取得
- `POST /api/management/users` - ユーザー作成
- `PUT /api/management/users/:id` - ユーザー更新
- `DELETE /api/management/users/:id` - ユーザー削除

#### クライアント管理

- `GET /api/management/clients` - クライアント一覧取得
- `POST /api/management/clients` - クライアント登録
- `DELETE /api/management/clients/:id` - クライアント削除

### OIDC Endpoints

- `GET /.well-known/openid-configuration` - Discovery endpoint
- `POST /oidc/token` - Token endpoint
- `GET /oidc/userinfo` - UserInfo endpoint
- `POST /oidc/introspect` - Token introspection

## トラブルシューティング

### Kafkaが起動しない

```bash
# Zookeeperのヘルスチェック確認
docker compose logs zookeeper

# Kafkaを再起動
docker compose restart kafka
```

### データベース接続エラー

```bash
# DBコンテナの状態確認
docker compose ps db

# データベース再作成
docker compose exec web bin/rails db:drop db:create db:migrate
```

### フロントエンドが表示されない

```bash
# フロントエンドコンテナのログ確認
docker compose logs frontend

# ブラウザでハードリフレッシュ（Cmd+Shift+R / Ctrl+Shift+R）
```
