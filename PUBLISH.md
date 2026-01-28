# GitHub Container Registryへの公開手順

このドキュメントでは、テストイメージをGitHub Container Registry (ghcr.io)に公開する手順を説明します。

## 前提条件

- GitHubアカウント（Senna46）
- GitHub Personal Access Token（packages:write権限）
- Docker CLI

## 手順

### 1. GitHubリポジトリの作成（オプション）

```bash
# ブラウザでGitHubにアクセス
# https://github.com/new
# リポジトリ名: d6e-test-docker-skill
# Public/Private: Public推奨
```

### 2. Dockerイメージのビルド

```bash
cd ~/github.com/Senna46/d6e-test-docker-skill
docker build -t d6e-test-skill:latest .
```

### 3. GitHub Container Registryにログイン

```bash
# Personal Access Tokenを使用
echo $GITHUB_TOKEN | docker login ghcr.io -u Senna46 --password-stdin

# または直接入力
docker login ghcr.io -u Senna46
# Password: <Personal Access Token>
```

**Personal Access Tokenの作成方法**:
1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. "Generate new token (classic)"
3. スコープで `write:packages` と `read:packages` を選択
4. トークンをコピー

### 4. イメージのタグ付け

```bash
docker tag d6e-test-skill:latest ghcr.io/senna46/d6e-test-docker-skill:latest
docker tag d6e-test-skill:latest ghcr.io/senna46/d6e-test-docker-skill:v1.0.0
```

### 5. イメージのプッシュ

```bash
docker push ghcr.io/senna46/d6e-test-docker-skill:latest
docker push ghcr.io/senna46/d6e-test-docker-skill:v1.0.0
```

### 6. イメージの公開設定

デフォルトでイメージはプライベートになります。パブリックにする場合：

1. https://github.com/users/Senna46/packages にアクセス
2. `d6e-test-docker-skill` パッケージをクリック
3. "Package settings" をクリック
4. "Change visibility" → "Public" に変更

### 7. イメージの確認

```bash
# パブリックイメージの場合、ログインなしでpull可能
docker pull ghcr.io/senna46/d6e-test-docker-skill:latest

# イメージ情報を確認
docker images | grep d6e-test-docker-skill
```

### 8. ローカルテスト

```bash
# ローカルのイメージを削除
docker rmi d6e-test-skill:latest
docker rmi ghcr.io/senna46/d6e-test-docker-skill:latest

# ghcr.ioからpullして実行
docker pull ghcr.io/senna46/d6e-test-docker-skill:latest

# テスト実行
echo '{"workspace_id":"01234567-89ab-cdef-0123-456789abcdef","stf_id":"01234567-89ab-cdef-0123-456789abcdef","input":{"operation":"test"},"sources":{},"caller":null,"api_url":"http://host.docker.internal:8080","api_token":"d6e-internal-stf-execution"}' | \
  docker run --rm -i ghcr.io/senna46/d6e-test-docker-skill:latest
```

## D6Eでの使用

STFバージョンを作成する際、公開したイメージを指定：

```javascript
// MCPツール: d6e_create_stf_version
{
  "stf_id": "{stf_id}",
  "version": "1.0.0",
  "runtime": "docker",
  "code": "{\"image\":\"ghcr.io/senna46/d6e-test-docker-skill:latest\"}"
}
```

## トラブルシューティング

### 認証エラー

```bash
# 再度ログイン
docker logout ghcr.io
docker login ghcr.io -u Senna46
```

### プッシュエラー

```bash
# パッケージが存在しない、または権限がない
# → GitHubでパッケージを作成するか、トークンの権限を確認
```

### Pullエラー（プライベートイメージ）

```bash
# プライベートイメージの場合、APIサーバーからもログインが必要
docker exec d6e-api-1 docker login ghcr.io -u Senna46
# または
# compose.withdb.ymlに認証情報を追加
```

## 自動化スクリプト

以下のスクリプトで自動的に公開できます：

```bash
cd ~/github.com/Senna46/d6e-test-docker-skill
./publish.sh
```
