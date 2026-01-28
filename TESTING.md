# テスト手順

このドキュメントでは、実際に D6E Docker Runtime をテストする手順を説明します。

## 1. ローカルでの基本テスト（D6E サーバー不要）

まず Docker イメージが正しく動作するか確認します。

```bash
cd ~/github.com/Senna46/d6e-test-docker-skill

# 自動テストを実行
./test-local.sh

# または手動で
make build
make test-local
```

**期待される出力**:

```json
{"output": {"status": "success", "message": "Docker STF test execution successful", ...}}
```

## 2. D6E サーバーでの統合テスト

### 2.1 D6E サーバーの起動

```bash
cd /home/user/github.com/KimuraYu45z/d6e
docker compose -f compose.withdb.yml up -d
```

サーバーが起動したら以下で確認：

```bash
curl http://localhost:8080/health
# 200 OK
```

### 2.2 ワークスペースとユーザーの準備

D6E フロントエンド（http://localhost:3000）にアクセスして：

1. ユーザー登録/ログイン
2. ワークスペース作成
3. ワークスペース ID をメモ

### 2.3 MCP ツールの準備

MCP ツールが使える環境を準備（Cursor AI など）

### 2.4 テストテーブルの作成

```javascript
// MCPツール: d6e_sql
{
  "sql": "CREATE TABLE test_data (id UUID PRIMARY KEY DEFAULT uuidv7(), name TEXT NOT NULL, value INTEGER, created_at TIMESTAMPTZ DEFAULT NOW())"
}

// テストデータを挿入
{
  "sql": "INSERT INTO test_data (name, value) VALUES ('Test 1', 100), ('Test 2', 200), ('Test 3', 300)"
}
```

### 2.5 STF の作成

```javascript
// MCPツール: d6e_create_stf
{
  "name": "test-docker-skill",
  "description": "Test Docker STF for validation"
}
```

返ってきた STF ID をメモ（例: `stf_id = "019abc..."`）

### 2.6 STF バージョンの作成

```javascript
// MCPツール: d6e_create_stf_version
{
  "stf_id": "{上記のSTF ID}",
  "version": "1.0.0",
  "runtime": "docker",
  "code": "{\"image\":\"d6e-test-skill:latest\"}"
}
```

**注意**: `code`フィールドは JSON 文字列です。

### 2.7 ポリシーグループとポリシーの作成

```javascript
// 1. ポリシーグループを作成
// MCPツール: d6e_create_policy_group
{
  "name": "docker-test-policy-group"
}

// 返ってきたpolicy_group_idをメモ

// 2. STFをポリシーグループに追加
// MCPツール: d6e_add_member_to_policy_group
{
  "policy_group_id": "{上記のpolicy_group_id}",
  "member_type": "stf",
  "member_id": "{STF ID}"
}

// 3. SELECT, INSERT, UPDATEポリシーを作成
// MCPツール: d6e_create_policy
{
  "policy_group_id": "{policy_group_id}",
  "table_name": "test_data",
  "operation": "select",
  "mode": "allow"
}

{
  "policy_group_id": "{policy_group_id}",
  "table_name": "test_data",
  "operation": "insert",
  "mode": "allow"
}

{
  "policy_group_id": "{policy_group_id}",
  "table_name": "test_data",
  "operation": "update",
  "mode": "allow"
}
```

### 2.8 ワークフローの作成

```javascript
// MCPツール: d6e_create_workflow
{
  "name": "test-docker-workflow",
  "description": "Workflow for testing Docker STF",
  "input_steps": [],
  "stf_steps": [
    {
      "stf_id": "{STF ID}",
      "version": "1.0.0"
    }
  ],
  "effect_steps": []
}
```

返ってきた workflow_id をメモ

### 2.9 テスト実行

#### テスト 1: 基本的な入出力

```javascript
// MCPツール: d6e_execute_workflow
{
  "workflow_id": "{workflow_id}",
  "input": {
    "operation": "test"
  }
}
```

**期待結果**:

```json
{
  "status": "success",
  "message": "Docker STF test execution successful",
  ...
}
```

#### テスト 2: SQL SELECT

```javascript
// MCPツール: d6e_execute_workflow
{
  "workflow_id": "{workflow_id}",
  "input": {
    "operation": "sql_select",
    "table_name": "test_data"
  }
}
```

**期待結果**:

```json
{
  "status": "success",
  "operation": "sql_select",
  "rows": [
    {"id": "...", "name": "Test 1", "value": 100, ...},
    {"id": "...", "name": "Test 2", "value": 200, ...},
    {"id": "...", "name": "Test 3", "value": 300, ...}
  ],
  "count": 3
}
```

#### テスト 3: SQL INSERT

```javascript
// MCPツール: d6e_execute_workflow
{
  "workflow_id": "{workflow_id}",
  "input": {
    "operation": "sql_insert",
    "table_name": "test_data",
    "data": {
      "name": "New Test",
      "value": 999
    }
  }
}
```

**期待結果**:

```json
{
  "status": "success",
  "operation": "sql_insert",
  "inserted": [
    {"id": "...", "name": "New Test", "value": 999, ...}
  ]
}
```

#### テスト 4: SQL UPDATE

```javascript
// MCPツール: d6e_execute_workflow
{
  "workflow_id": "{workflow_id}",
  "input": {
    "operation": "sql_update",
    "table_name": "test_data",
    "set": {
      "value": 1000
    },
    "where": "name = 'Test 1'"
  }
}
```

**期待結果**:

```json
{
  "status": "success",
  "operation": "sql_update",
  "affected_rows": 1
}
```

#### テスト 5: エラーハンドリング

```javascript
// MCPツール: d6e_execute_workflow
{
  "workflow_id": "{workflow_id}",
  "input": {
    "operation": "error"
  }
}
```

**期待結果**: エラーが返される

```json
{
  "status": "error",
  "error": "Intentional error for testing"
}
```

## 3. ログの確認

テスト実行中、API サーバーのログを確認：

```bash
# APIコンテナのログをリアルタイムで表示
docker logs d6e-api-1 -f

# Docker STF実行のログが表示されるはず
# 例:
# INFO Executing Docker STF: workspace=..., stf=..., image=d6e-test-skill:latest
# INFO Docker STF execution completed: workspace=..., stf=...
```

## トラブルシューティング

### イメージが見つからない

```bash
# APIコンテナから見えるイメージを確認
docker exec d6e-api-1 docker images

# d6e-test-skill:latestが表示されない場合
# → APIコンテナが参照するのはホストのDocker daemon
# → ホスト側でビルドしていることを確認
docker images | grep d6e-test-skill
```

### SQL 実行エラー

```bash
# ポリシーを確認
# MCPツール: d6e_list_policies で確認
```

### タイムアウト

長時間実行される場合、環境変数で調整：

```yaml
# compose.withdb.yml
api:
  environment:
    STF_DOCKER_TIMEOUT_SECS: "600" # 10分
```

## 成功の確認

すべてのテストが成功したら、以下が確認できたことになります：

✅ Docker イメージの起動
✅ stdin/stdout での JSON 通信
✅ 内部 API 経由の SQL 実行
✅ ポリシーに基づくアクセス制御
✅ エラーハンドリング
✅ ログ出力

おめでとうございます！Docker Runtime 機能は正常に動作しています。
