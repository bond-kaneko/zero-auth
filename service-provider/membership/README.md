# Membership Service

Organization/Role/Membership管理サービス

## 概要

membershipサービスは、組織（Organization）、役割（Role）、メンバーシップ（Membership）を管理するマイクロサービスです。id-providerからイベント駆動でユーザー情報を同期し、組織単位でのアクセス制御を実現します。

### 主な機能

- **Organization管理**: 組織の作成・更新・削除
- **Role管理**: 組織内の役割定義・管理
- **Membership管理**: ユーザーと役割の紐付け
- **User同期**: id-providerからKafka経由でユーザー情報を自動同期
- **REST API**: Organization/Role/Membership操作用のAPI
- **フロントエンド**: 管理画面（React + Vite）

### 技術スタック

- **Backend**: Ruby on Rails 8.1.1
- **Database**: PostgreSQL
- **Message Consumer**: Karafka (Kafka consumer framework)
- **Frontend**: React 19 + Vite + TypeScript
- **Styling**: Tailwind CSS

## 起動方法

### 前提条件

- Docker & Docker Compose がインストールされていること
- id-provider（Kafka含む）が起動していること
- `/etc/hosts` に以下を追加:
  ```
  127.0.0.1 membership.local
  ```
- SSL証明書が `../../ssl/` ディレクトリに存在すること

### 環境変数設定

`.env` ファイルを作成:

```env
RAILS_ENV=development
DATABASE_URL=postgres://postgres:postgres@db:5432/membership_development
KAFKA_BROKERS=kafka:9092
ID_PROVIDER_URL=https://id-provider.local:3443
```

### コンテナ起動

```bash
# すべてのサービスを起動（DB, Web, Worker, Frontend, Nginx）
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

- **フロントエンド**: https://membership.local:3445
- **API**: https://membership.local:3445/api

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

# 自動修正
docker compose exec web bundle exec rubocop -A
```

### データベースリセット

```bash
docker compose exec web bin/rails db:reset
```

## アーキテクチャ

### サービス構成

- **db**: PostgreSQLデータベース（ポート5432）
- **web**: Rails APIサーバー（ポート3002）
- **worker**: Karafka consumer（Kafkaイベント処理）
- **frontend**: React開発サーバー（ポート5173）
- **nginx**: リバースプロキシ（ポート443 → 3445）

### イベント駆動ユーザー同期

id-providerのKafka `user-events` トピックからユーザーイベントを受信し、自動同期します。

**処理フロー**:
```
id-provider (User作成/削除)
  ↓ Kafka publish
user-events topic
  ↓ Karafka consume
membership/worker
  ↓ イベント処理
UserSyncService
  ↓ DB操作
membership DB
```

**対応イベント**:
- `user.created` → ユーザーレコード作成
- `user.deleted` → ユーザーレコード削除

### データモデル

```
Organization (組織)
  ├─ Role (役割)
  │   └─ Membership (メンバーシップ)
  │       └─ User (ユーザー)
  └─ Membership (組織全体のメンバー)
      └─ User
```

- **Organization**: テナント（組織）
- **Role**: 組織内の役割（例: Admin, Member, Viewer）
- **Membership**: ユーザーと役割の紐付け
- **User**: id-providerから同期されたユーザー情報

## API仕様

### Organizations API

- `GET /api/organizations` - 組織一覧取得
- `GET /api/organizations/:id` - 組織詳細取得
- `POST /api/organizations` - 組織作成
- `PUT /api/organizations/:id` - 組織更新
- `DELETE /api/organizations/:id` - 組織削除
- `GET /api/organizations/:id/memberships` - 組織のメンバー一覧

### Roles API

- `GET /api/organizations/:organization_id/roles` - 役割一覧取得
- `POST /api/organizations/:organization_id/roles` - 役割作成
- `PUT /api/roles/:id` - 役割更新
- `DELETE /api/roles/:id` - 役割削除

### Memberships API

- `POST /api/roles/:role_id/memberships` - メンバーシップ作成
- `DELETE /api/memberships/:id` - メンバーシップ削除

### Users API

- `GET /api/users` - ユーザー一覧取得（検索対応）
- `POST /api/users/sync` - id-providerからの手動同期

## イベント消費の抽象化

将来的に他のメッセージングシステム（AWS SQS, Google Pub/Subなど）に切り替え可能な抽象化レイヤーを実装しています。

```ruby
# 環境変数でconsumer切り替え可能
ENV['EVENT_CONSUMER_TYPE'] = 'karafka'  # デフォルト

# 抽象インターフェース
Events::EventConsumer.current.consume(event_type:, payload:)

# 実装
Events::KarafkaEventConsumer  # Kafka実装
# 将来: Events::SqsEventConsumer, Events::PubSubEventConsumer など
```

## トラブルシューティング

### Workerがイベントを受信しない

```bash
# Workerコンテナのログ確認
docker compose logs worker -f

# id-providerのKafkaが起動しているか確認
cd ../../id-provider
docker compose ps kafka

# Kafkaトピック確認
docker compose exec kafka kafka-topics --list --bootstrap-server localhost:9092
```

### ユーザーが同期されない

```bash
# Workerの状態確認
docker compose ps worker

# Karafka設定確認
docker compose exec worker bundle exec karafka info

# 手動同期実行
docker compose exec web bin/rails runner "UserSyncService.new.sync"
```

### フロントエンドが表示されない

```bash
# Frontendコンテナのログ確認
docker compose logs frontend -f

# Nginxの状態確認
docker compose ps nginx

# ブラウザでハードリフレッシュ（Cmd+Shift+R / Ctrl+Shift+R）
```

### データベース接続エラー

```bash
# DBコンテナの状態確認
docker compose ps db

# データベース再作成
docker compose exec web bin/rails db:drop db:create db:migrate
```

## フロントエンド開発

### ディレクトリ構造

```
frontend/
├── src/
│   ├── api/          # APIクライアント
│   ├── components/   # 共通コンポーネント
│   ├── pages/        # ページコンポーネント
│   ├── types/        # TypeScript型定義
│   ├── App.tsx       # ルーティング
│   └── main.tsx      # エントリーポイント
├── index.html
├── package.json
└── vite.config.ts
```

### 開発サーバー

```bash
# フロントエンドコンテナ内で実行
cd frontend
npm run dev
```

### 型チェック

```bash
cd frontend
npm run type-check
```

### Lint

```bash
cd frontend
npm run lint
```
