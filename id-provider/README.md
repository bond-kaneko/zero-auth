# ID Provider

OpenID Connect Identity Provider (認証サーバー)

## セットアップ

詳細はプロジェクトルートの [README.md](../README.md) を参照してください。

### クイックスタート

1. SSL証明書が生成されていることを確認（プロジェクトルートの `ssl/` ディレクトリ）
2. `/etc/hosts` に `id-provider.local` が設定されていることを確認
3. 環境変数ファイル `.env` を作成（必要に応じて）
4. 起動:

```bash
docker compose up
```

5. アクセス: `https://id-provider.local:3443`

## データベースのセットアップ

```bash
docker compose exec web bin/rails db:create
docker compose exec web bin/rails db:migrate
```
