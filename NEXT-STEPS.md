# 次のステップ: GitHub Container Registryへの公開

## 現在の状態

✅ Dockerイメージのビルド完了
✅ ローカルテスト成功
⏳ GitHub Container Registryへの公開（これから実行）

## 手順

### 1. GitHub Personal Access Tokenの作成

1. ブラウザで https://github.com/settings/tokens を開く
2. "Generate new token" をクリック
3. "Generate new token (classic)" を選択
4. 設定:
   - **Note**: `d6e-docker-publish`
   - **Expiration**: 90 days（または任意）
   - **Select scopes**:
     - ✅ `write:packages` - パッケージの書き込み
     - ✅ `read:packages` - パッケージの読み取り
5. "Generate token" をクリック
6. **トークンをコピー**（このページを離れると二度と表示されません！）

### 2. Dockerログイン

```bash
# 方法1: トークンを環境変数に設定（推奨）
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"
echo $GITHUB_TOKEN | docker login ghcr.io -u Senna46 --password-stdin

# 方法2: 直接入力
docker login ghcr.io -u Senna46
# Password: [トークンを貼り付け]
```

成功すると:
```
Login Succeeded
```

### 3. イメージの公開

```bash
cd ~/github.com/Senna46/d6e-test-docker-skill
./publish.sh
```

これにより以下が自動実行されます:
1. イメージのビルド
2. `ghcr.io/senna46/d6e-test-docker-skill:latest` としてタグ付け
3. `ghcr.io/senna46/d6e-test-docker-skill:v1.0.0` としてタグ付け
4. GitHub Container Registryへプッシュ

### 4. イメージの公開設定（パブリックにする）

デフォルトではプライベートなので、パブリックに変更:

1. https://github.com/users/Senna46/packages を開く
2. `d6e-test-docker-skill` パッケージをクリック
3. 右上の "Package settings" をクリック
4. "Danger Zone" セクションの "Change visibility" をクリック
5. "Public" を選択
6. パッケージ名 `d6e-test-docker-skill` を入力して確認
7. "I understand, change package visibility" をクリック

### 5. 公開イメージのテスト

```bash
cd ~/github.com/Senna46/d6e-test-docker-skill
./test-published.sh
```

これにより:
1. ローカルイメージを削除
2. ghcr.ioからpull
3. 各種テストを自動実行

### 6. D6Eでの使用

#### 6-1. D6Eサーバーを起動

```bash
cd /home/user/github.com/KimuraYu45z/d6e
docker compose -f compose.withdb.yml up -d

# ヘルスチェック
curl http://localhost:8080/health
```

#### 6-2. STFとワークフローを作成

MCPツール（Cursor AIなど）で実行:

```javascript
// 1. STF作成
d6e_create_stf({
  "name": "test-ghcr-docker-skill",
  "description": "Test Docker STF from GitHub Container Registry"
})
// → stf_id をメモ

// 2. STFバージョン作成（ghcr.ioイメージを指定）
d6e_create_stf_version({
  "stf_id": "{上記のstf_id}",
  "version": "1.0.0",
  "runtime": "docker",
  "code": "{\"image\":\"ghcr.io/senna46/d6e-test-docker-skill:latest\"}"
})

// 3. テストテーブルとデータを作成
d6e_sql({
  "sql": "CREATE TABLE test_data (id UUID PRIMARY KEY DEFAULT uuidv7(), name TEXT NOT NULL, value INTEGER, created_at TIMESTAMPTZ DEFAULT NOW())"
})

d6e_sql({
  "sql": "INSERT INTO test_data (name, value) VALUES ('Test 1', 100), ('Test 2', 200), ('Test 3', 300)"
})

// 4. ポリシーグループ作成
d6e_create_policy_group({
  "name": "docker-test-group"
})
// → policy_group_id をメモ

// 5. STFをポリシーグループに追加
d6e_add_member_to_policy_group({
  "policy_group_id": "{policy_group_id}",
  "member_type": "stf",
  "member_id": "{stf_id}"
})

// 6. ポリシー作成（select, insert, update）
d6e_create_policy({
  "policy_group_id": "{policy_group_id}",
  "table_name": "test_data",
  "operation": "select",
  "mode": "allow"
})

d6e_create_policy({
  "policy_group_id": "{policy_group_id}",
  "table_name": "test_data",
  "operation": "insert",
  "mode": "allow"
})

d6e_create_policy({
  "policy_group_id": "{policy_group_id}",
  "table_name": "test_data",
  "operation": "update",
  "mode": "allow"
})

// 7. ワークフロー作成
d6e_create_workflow({
  "name": "test-ghcr-workflow",
  "input_steps": [],
  "stf_steps": [
    {
      "stf_id": "{stf_id}",
      "version": "1.0.0"
    }
  ],
  "effect_steps": []
})
// → workflow_id をメモ

// 8. 実行テスト
d6e_execute_workflow({
  "workflow_id": "{workflow_id}",
  "input": {
    "operation": "test"
  }
})

// 9. SQL SELECTテスト
d6e_execute_workflow({
  "workflow_id": "{workflow_id}",
  "input": {
    "operation": "sql_select",
    "table_name": "test_data"
  }
})

// 10. SQL INSERTテスト
d6e_execute_workflow({
  "workflow_id": "{workflow_id}",
  "input": {
    "operation": "sql_insert",
    "table_name": "test_data",
    "data": {
      "name": "New Test",
      "value": 999
    }
  }
})
```

## トラブルシューティング

### ログイン失敗

```bash
# 再度ログイン
docker logout ghcr.io
docker login ghcr.io -u Senna46
```

### プッシュ失敗: "unauthorized"

- Personal Access Tokenが正しいか確認
- トークンに `write:packages` 権限があるか確認
- トークンの有効期限が切れていないか確認

### D6Eでイメージがpullできない（プライベートの場合）

```bash
# APIコンテナ内でもログイン
docker exec -it d6e-api-1 docker login ghcr.io -u Senna46
```

## 完了チェックリスト

- [ ] GitHub Personal Access Token作成
- [ ] Docker loginに成功
- [ ] `./publish.sh` でイメージ公開
- [ ] イメージをPublicに設定
- [ ] `./test-published.sh` でテスト成功
- [ ] D6Eサーバー起動
- [ ] STFとワークフロー作成
- [ ] D6Eでの実行テスト成功

すべてチェックがついたら、Docker Runtime機能が完全に動作していることが確認できます！🎉

## 次の展開

1. **独自のスキルを作成**: Python/Node.js/Goで独自のビジネスロジックを実装
2. **ghcr.ioに公開**: `ghcr.io/your-org/your-skill` として公開
3. **READMEを作成**: AIエージェントが理解できるドキュメント
4. **本番環境へ**: 実際のワークフローで使用

Happy Coding! 🚀
