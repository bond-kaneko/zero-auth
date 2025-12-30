# zero-auth

OpenID Connect (OIDC) を使った認証システムのホビープロジェクト。

## 構成

- `id-provider/`: OIDC Identity Provider (認証サーバー)
- `service-provider/`: OIDC Client (サービスプロバイダー)

## セットアップ

### 前提条件

- Docker & Docker Compose
- mkcert (ローカルHTTPS証明書生成用)

### 1. mkcertのインストール

```bash
# macOS
brew install mkcert

# ローカルCAをインストール（初回のみ）
mkcert -install
```

### 2. SSL証明書の生成

**重要**: SSL証明書ファイルは `.gitignore` に含まれているため、生成する必要があります。

プロジェクトルートで実行：

```bash
# sslディレクトリを作成
mkdir -p ssl

# 証明書を生成（両方のドメインを含む）
cd ssl
mkcert id-provider.local service-provider.local

# 生成されたファイルを確認
# id-provider.local+1.pem と id-provider.local+1-key.pem が生成される
```

### 3. /etc/hostsの設定

ローカルドメインを解決できるように設定：

```bash
sudo sh -c 'echo "127.0.0.1 id-provider.local" >> /etc/hosts'
sudo sh -c 'echo "127.0.0.1 service-provider.local" >> /etc/hosts'
```

### 4. 環境変数の設定

#### id-provider

`id-provider/.env` ファイルを作成（必要に応じて）：

```env
DATABASE_HOST=db
DATABASE_USER=postgres
DATABASE_PASSWORD=postgres
DATABASE_NAME=id_provider_development
RAILS_ENV=development
```

#### service-provider

`service-provider/.env` ファイルを作成：

```env
RAILS_ENV=development
OIDC_ISSUER=https://id-provider.local:3443
OIDC_CLIENT_ID=your_client_id
OIDC_CLIENT_SECRET=your_client_secret
OIDC_REDIRECT_URI=https://service-provider.local:3444/auth/callback
```

### 5. アプリケーションの起動

#### id-provider

```bash
cd id-provider
docker compose up
```

アクセス: `https://id-provider.local:3443`

#### service-provider

```bash
cd service-provider
docker compose up
```

アクセス: `https://service-provider.local:3444`

## 開発環境でのHTTPS通信

開発環境では、mkcertで生成した自己署名証明書を使用してHTTPS通信を行います。

- **id-provider**: `https://id-provider.local:3443`
- **service-provider**: `https://service-provider.local:3444`

nginxがリバースプロキシとして動作し、SSL終端を行います。

## データベースのセットアップ

### id-provider

```bash
cd id-provider
docker compose exec web bin/rails db:create
docker compose exec web bin/rails db:migrate
```
