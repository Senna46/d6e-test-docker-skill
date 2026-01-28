# D6E Test Docker Skill

テスト用のDocker STFイメージです。D6E Docker Runtimeの機能検証に使用します。

**Docker Image**: `ghcr.io/senna46/d6e-test-docker-skill:latest`

## LLM/AIエージェント向け使用方法

このDockerイメージをD6E AIエージェントから使用する場合、以下の手順でSTFを作成してください。

### ステップ1: STFの作成

```javascript
d6e_create_stf({
  "name": "test-docker-skill",
  "description": "Docker-based test skill for data operations"
})
```

### ステップ2: STFバージョンの作成

```javascript
d6e_create_stf_version({
  "stf_id": "{ステップ1で取得したstf_id}",
  "version": "1.0.0",
  "runtime": "docker",
  "code": "{\"image\":\"ghcr.io/senna46/d6e-test-docker-skill:latest\"}"
})
```

**重要**: `runtime`は必ず`"docker"`を指定し、`code`フィールドにはJSON文字列として`{"image":"ghcr.io/senna46/d6e-test-docker-skill:latest"}`を設定してください。

### ステップ3: ワークフローの作成

```javascript
d6e_create_workflow({
  "name": "test-docker-workflow",
  "input_steps": [],
  "stf_steps": [
    {
      "stf_id": "{stf_id}",
      "version": "1.0.0"
    }
  ],
  "effect_steps": []
})
```

### ステップ4: ワークフローの実行

```javascript
// 基本テスト
d6e_execute_workflow({
  "workflow_id": "{ステップ3で取得したworkflow_id}",
  "input": {
    "operation": "test"
  }
})

// SQL SELECT実行（テーブルが存在する場合）
d6e_execute_workflow({
  "workflow_id": "{workflow_id}",
  "input": {
    "operation": "sql_select",
    "table_name": "test_data"
  }
})

// SQL INSERT実行（ポリシーが設定されている場合）
d6e_execute_workflow({
  "workflow_id": "{workflow_id}",
  "input": {
    "operation": "sql_insert",
    "table_name": "test_data",
    "data": {
      "name": "New Record",
      "value": 100
    }
  }
})
```

## イメージのビルド（開発者向け）

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

## 📚 AIエージェント向けドキュメント

LLMにこのスキルを使わせる場合、以下のプロンプトを提供してください：

```
D6EでDockerベースのデータ処理スキルを使用してください。

Docker Image: ghcr.io/senna46/d6e-test-docker-skill:latest

このスキルの使用方法:
1. d6e_create_stf でSTFを作成
2. d6e_create_stf_version で runtime: "docker", code: "{\"image\":\"ghcr.io/senna46/d6e-test-docker-skill:latest\"}" を指定
3. d6e_create_workflow でワークフローを作成
4. d6e_execute_workflow で実行

サポートされている操作:
- operation: "test" - 基本テスト
- operation: "sql_select" - データ取得（table_name指定）
- operation: "sql_insert" - データ挿入（table_name, data指定）
- operation: "sql_update" - データ更新（table_name, set, where指定）

詳細は README.md の「LLM/AIエージェント向け使用方法」セクションを参照。
```

より詳細なプロンプト例は [LLM-PROMPT.md](./LLM-PROMPT.md) を参照してください。

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
