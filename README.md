# D6E Test Docker Skill

テスト用のDocker STFイメージです。D6E Docker Runtimeの機能検証に使用します。

## イメージのビルド

```bash
docker build -t d6e-test-skill:latest .
```

## 使用方法

### 基本的なテスト

```json
{
  "input": {
    "operation": "test"
  },
  "sources": {}
}
```

**出力**:
```json
{
  "output": {
    "status": "success",
    "message": "Docker STF test execution successful",
    "received_input": {...},
    "received_sources": [],
    "caller": "..."
  }
}
```

### SQL SELECTテスト

```json
{
  "input": {
    "operation": "sql_select",
    "table_name": "test_table"
  },
  "sources": {}
}
```

**出力**:
```json
{
  "output": {
    "status": "success",
    "operation": "sql_select",
    "table": "test_table",
    "rows": [...],
    "count": 10
  }
}
```

### SQL INSERTテスト

```json
{
  "input": {
    "operation": "sql_insert",
    "table_name": "test_table",
    "data": {
      "name": "Test Name",
      "value": 123
    }
  },
  "sources": {}
}
```

**出力**:
```json
{
  "output": {
    "status": "success",
    "operation": "sql_insert",
    "table": "test_table",
    "inserted": [...]
  }
}
```

### SQL UPDATEテスト

```json
{
  "input": {
    "operation": "sql_update",
    "table_name": "test_table",
    "set": {
      "status": "updated"
    },
    "where": "id = '...'"
  },
  "sources": {}
}
```

**出力**:
```json
{
  "output": {
    "status": "success",
    "operation": "sql_update",
    "table": "test_table",
    "affected_rows": 1
  }
}
```

### エラーハンドリングテスト

```json
{
  "input": {
    "operation": "error"
  },
  "sources": {}
}
```

**出力**:
```json
{
  "output": {
    "status": "error",
    "error": "Intentional error for testing"
  }
}
```

## イメージの公開

### GitHub Container Registry (ghcr.io) への公開

詳細は [README-GHCR.md](./README-GHCR.md) を参照してください。

```bash
# クイックスタート
docker login ghcr.io -u Senna46
./publish.sh
./test-published.sh
```

公開後のイメージ: `ghcr.io/senna46/d6e-test-docker-skill:latest`

## D6Eでの使用

### 1. STFの作成

```bash
# d6e_create_stf MCPツールを使用
{
  "name": "test-docker-skill",
  "description": "Test Docker STF"
}
```

### 2. STFバージョンの作成

```bash
# d6e_create_stf_version MCPツールを使用
{
  "stf_id": "...",
  "version": "1.0.0",
  "runtime": "docker",
  "code": "{\"image\":\"d6e-test-skill:latest\"}"
}
```

**注意**: `code`フィールドはJSONをbase64エンコードした文字列として渡す必要がある場合があります。

### 3. ワークフローの作成と実行

```bash
# d6e_create_workflow MCPツールを使用
{
  "name": "test-docker-workflow",
  "stf_steps": [
    {
      "stf_id": "...",
      "version": "1.0.0"
    }
  ]
}

# d6e_execute_workflow MCPツールを使用
{
  "workflow_id": "...",
  "input": {
    "operation": "test"
  }
}
```

## テスト項目

- [x] 入力データの受信（input, sources, caller）
- [x] SQL SELECT実行
- [x] SQL INSERT実行
- [x] SQL UPDATE実行
- [x] エラーハンドリング
- [x] ログ出力（stderr）
- [x] JSON出力（stdout）

## トラブルシューティング

### Dockerイメージが見つからない

```bash
# イメージが存在することを確認
docker images | grep d6e-test-skill

# 必要に応じて再ビルド
docker build -t d6e-test-skill:latest .
```

### SQL実行エラー

テーブルが存在しない場合は、まず作成してください：

```sql
CREATE TABLE test_table (
  id UUID PRIMARY KEY DEFAULT uuidv7(),
  name TEXT,
  value INTEGER,
  status TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

ポリシーが設定されていない場合は、ポリシーグループとポリシーを作成してください。

## システム要件

- Docker
- D6E API server (with Docker socket mounted)
- Python 3.11+ (イメージ内)
- requests library (イメージ内)
