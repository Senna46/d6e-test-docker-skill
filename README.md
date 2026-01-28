# D6E Test Docker Skill

テスト用の Docker STF イメージです。D6E Docker Runtime の機能検証に使用します。

**Docker Image**: `ghcr.io/senna46/d6e-test-docker-skill:latest`

## LLM/AI エージェント向け使用方法

この Docker イメージを D6E AI エージェントから使用する場合、以下の手順で STF を作成してください。

### ステップ 1: STF の作成

```javascript
d6e_create_stf({
  name: "test-docker-skill",
  description: "Docker-based test skill for data operations",
});
```

### ステップ 2: STF バージョンの作成

```javascript
d6e_create_stf_version({
  stf_id: "{ステップ1で取得したstf_id}",
  version: "1.0.0",
  runtime: "docker",
  code: '{"image":"ghcr.io/senna46/d6e-test-docker-skill:latest"}',
});
```

**重要**: `runtime`は必ず`"docker"`を指定し、`code`フィールドには JSON 文字列として`{"image":"ghcr.io/senna46/d6e-test-docker-skill:latest"}`を設定してください。

### ステップ 3: ワークフローの作成

```javascript
d6e_create_workflow({
  name: "test-docker-workflow",
  input_steps: [],
  stf_steps: [
    {
      stf_id: "{stf_id}",
      version: "1.0.0",
    },
  ],
  effect_steps: [],
});
```

### ステップ 4: ワークフローの実行

```javascript
// 基本テスト
d6e_execute_workflow({
  workflow_id: "{ステップ3で取得したworkflow_id}",
  input: {
    operation: "test",
  },
});

// SQL SELECT実行（テーブルが存在する場合）
d6e_execute_workflow({
  workflow_id: "{workflow_id}",
  input: {
    operation: "sql_select",
    table_name: "test_data",
  },
});

// SQL INSERT実行（ポリシーが設定されている場合）
d6e_execute_workflow({
  workflow_id: "{workflow_id}",
  input: {
    operation: "sql_insert",
    table_name: "test_data",
    data: {
      name: "New Record",
      value: 100,
    },
  },
});
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

### SQL SELECT テスト

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

### SQL INSERT テスト

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

### SQL UPDATE テスト

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

## 🤖 AI エージェントへのプロンプト

### 基本プロンプト

```
D6EでDockerベースのデータ処理スキルを使用してください。

Docker Image: ghcr.io/senna46/d6e-test-docker-skill:latest
README: https://github.com/Senna46/d6e-test-docker-skill

使用手順:
1. d6e_create_stf でSTFを作成
2. d6e_create_stf_version で以下を指定:
   - runtime: "docker"
   - code: "{\"image\":\"ghcr.io/senna46/d6e-test-docker-skill:latest\"}"
3. d6e_create_workflow でワークフローを作成
4. d6e_execute_workflow で実行

サポートされている操作:
- "test": 基本動作確認
- "sql_select": データ取得（table_name必須）
- "sql_insert": データ挿入（table_name, data必須）
- "sql_update": データ更新（table_name, set必須、whereオプション）

まずは operation: "test" で動作確認してください。
```

### SQL を使う場合のプロンプト

```
test_dataテーブルのデータを取得して表示してください。

使用スキル:
- Docker Image: ghcr.io/senna46/d6e-test-docker-skill:latest
- 操作: sql_select
- テーブル: test_data

手順:
1. STFとワークフローを作成（runtime: "docker"）
2. ポリシーが設定されていることを確認（なければ作成）
3. operation: "sql_select", table_name: "test_data" で実行

注意: テーブルとポリシーが存在しない場合は、まず作成してください。
```

### 完全な実行例プロンプト

```
test_dataテーブルを作成し、Docker STFを使ってデータを取得してください。

Docker Image: ghcr.io/senna46/d6e-test-docker-skill:latest

実行ステップ:
1. テーブル作成:
   CREATE TABLE test_data (
     id UUID PRIMARY KEY DEFAULT uuidv7(),
     name TEXT NOT NULL,
     value INTEGER,
     created_at TIMESTAMPTZ DEFAULT NOW()
   )

2. テストデータ挿入:
   INSERT INTO test_data (name, value) VALUES ('Test 1', 100), ('Test 2', 200)

3. STF作成（name: "test-docker-skill", runtime: "docker"）

4. ポリシー設定:
   - ポリシーグループ作成
   - STFをグループに追加
   - SELECTポリシー作成（table: test_data）

5. ワークフロー作成・実行:
   - operation: "sql_select"
   - table_name: "test_data"

結果を表形式で表示してください。
```

より詳細なプロンプト例とエラー対処方法は [LLM-PROMPT.md](./LLM-PROMPT.md) を参照してください。

## D6E での使用

### 1. STF の作成

```bash
# d6e_create_stf MCPツールを使用
{
  "name": "test-docker-skill",
  "description": "Test Docker STF"
}
```

### 2. STF バージョンの作成

```bash
# d6e_create_stf_version MCPツールを使用
{
  "stf_id": "...",
  "version": "1.0.0",
  "runtime": "docker",
  "code": "{\"image\":\"d6e-test-skill:latest\"}"
}
```

**注意**: `code`フィールドは JSON を base64 エンコードした文字列として渡す必要がある場合があります。

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
- [x] SQL SELECT 実行
- [x] SQL INSERT 実行
- [x] SQL UPDATE 実行
- [x] エラーハンドリング
- [x] ログ出力（stderr）
- [x] JSON 出力（stdout）

## トラブルシューティング

### Docker イメージが見つからない

```bash
# イメージが存在することを確認
docker images | grep d6e-test-skill

# 必要に応じて再ビルド
docker build -t d6e-test-skill:latest .
```

### SQL 実行エラー

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
