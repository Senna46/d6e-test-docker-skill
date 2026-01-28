# GitHub Container Registryでのテスト手順

このドキュメントでは、イメージをghcr.ioに公開し、D6Eで使用するまでの完全な手順を説明します。

## クイックスタート

### 1. イメージのビルドと公開

```bash
cd ~/github.com/Senna46/d6e-test-docker-skill

# GitHubにログイン
docker login ghcr.io -u Senna46
# Password: <Personal Access Token>

# ビルド・タグ付け・プッシュを自動実行
./publish.sh
```

### 2. 公開イメージのテスト

```bash
# ローカルイメージを削除してghcr.ioからpullして動作確認
./test-published.sh
```

### 3. D6Eでの使用

```javascript
// STFバージョンを作成（ghcr.ioのイメージを使用）
d6e_create_stf_version({
  "stf_id": "{stf_id}",
  "version": "1.0.0",
  "runtime": "docker",
  "code": "{\"image\":\"ghcr.io/senna46/d6e-test-docker-skill:latest\"}"
})
```

## 詳細手順

### A. 初回セットアップ

#### A-1. GitHub Personal Access Tokenの作成

1. https://github.com/settings/tokens にアクセス
2. "Generate new token" → "Generate new token (classic)"
3. トークン名: `d6e-docker-publish`
4. スコープ:
   - ✅ `write:packages`
   - ✅ `read:packages`
   - ✅ `delete:packages` (オプション)
5. "Generate token"
6. トークンをコピー（後で使用）

#### A-2. Dockerにログイン

```bash
# 環境変数にトークンを設定
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"

# ログイン
echo $GITHUB_TOKEN | docker login ghcr.io -u Senna46 --password-stdin

# または直接入力
docker login ghcr.io -u Senna46
# Password: <貼り付け>
```

ログイン成功メッセージ：
```
Login Succeeded
```

### B. イメージの公開

#### B-1. 手動での公開

```bash
cd ~/github.com/Senna46/d6e-test-docker-skill

# ビルド
docker build -t d6e-test-skill:latest .

# タグ付け
docker tag d6e-test-skill:latest ghcr.io/senna46/d6e-test-docker-skill:latest
docker tag d6e-test-skill:latest ghcr.io/senna46/d6e-test-docker-skill:v1.0.0

# プッシュ
docker push ghcr.io/senna46/d6e-test-docker-skill:latest
docker push ghcr.io/senna46/d6e-test-docker-skill:v1.0.0
```

#### B-2. スクリプトでの自動公開（推奨）

```bash
./publish.sh
```

### C. イメージの公開設定

デフォルトではプライベートなので、パブリックにする：

1. https://github.com/users/Senna46/packages にアクセス
2. `d6e-test-docker-skill` をクリック
3. 右上の "Package settings" をクリック
4. "Danger Zone" → "Change visibility"
5. "Public" を選択
6. パッケージ名を入力して確認

### D. イメージのテスト

#### D-1. ローカルでのpull・実行テスト

```bash
# 自動テストスクリプト
./test-published.sh

# または手動で
docker pull ghcr.io/senna46/d6e-test-docker-skill:latest

echo '{"workspace_id":"01234567-89ab-cdef-0123-456789abcdef","stf_id":"01234567-89ab-cdef-0123-456789abcdef","input":{"operation":"test"},"sources":{},"caller":null,"api_url":"http://host.docker.internal:8080","api_token":"d6e-internal-stf-execution"}' | \
  docker run --rm -i ghcr.io/senna46/d6e-test-docker-skill:latest
```

期待される出力：
```json
{"output": {"status": "success", "message": "Docker STF test execution successful", ...}}
```

#### D-2. D6Eでの統合テスト

```bash
# D6Eサーバーを起動
cd /home/user/github.com/KimuraYu45z/d6e
docker compose -f compose.withdb.yml up -d
```

MCPツールで実行：

```javascript
// 1. STF作成
d6e_create_stf({
  "name": "test-ghcr-docker-skill",
  "description": "Test Docker STF from GitHub Container Registry"
})

// 2. STFバージョン作成（ghcr.ioのイメージを指定）
d6e_create_stf_version({
  "stf_id": "{stf_id from step 1}",
  "version": "1.0.0",
  "runtime": "docker",
  "code": "{\"image\":\"ghcr.io/senna46/d6e-test-docker-skill:latest\"}"
})

// 3. ポリシーグループ・ポリシー作成（省略、QUICKSTART.md参照）

// 4. ワークフロー作成
d6e_create_workflow({
  "name": "test-ghcr-workflow",
  "stf_steps": [
    {
      "stf_id": "{stf_id}",
      "version": "1.0.0"
    }
  ]
})

// 5. 実行
d6e_execute_workflow({
  "workflow_id": "{workflow_id}",
  "input": {
    "operation": "test"
  }
})
```

### E. プライベートイメージの場合

プライベートイメージを使う場合、APIコンテナからもログインが必要：

```bash
# APIコンテナ内でログイン
docker exec -it d6e-api-1 docker login ghcr.io -u Senna46
# Password: <Personal Access Token>
```

## トラブルシューティング

### "unauthorized: authentication required"

```bash
# ログイン状態を確認
cat ~/.docker/config.json | grep ghcr.io

# 再ログイン
docker logout ghcr.io
docker login ghcr.io -u Senna46
```

### "denied: permission_denied"

- Personal Access Tokenに `write:packages` 権限があるか確認
- トークンの有効期限が切れていないか確認

### イメージがpullできない（プライベートの場合）

```bash
# APIコンテナ内でもログイン
docker exec d6e-api-1 docker login ghcr.io -u Senna46
```

### イメージが古い

```bash
# キャッシュを無視して再ビルド
docker build --no-cache -t d6e-test-skill:latest .

# 再度公開
./publish.sh
```

## まとめ

✅ イメージをghcr.ioに公開
✅ パブリック/プライベート設定
✅ ローカルでpull・実行テスト
✅ D6Eでの統合テスト

これで、公開されたDockerイメージをD6Eで使用できるようになりました！

## 次のステップ

1. 独自のDockerスキルを作成
2. ghcr.io/your-org/your-skill として公開
3. READMEをLLMに提供
4. AIエージェントが自動的に使用
