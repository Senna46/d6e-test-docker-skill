# LLM向けプロンプト例

このドキュメントは、AIエージェント/LLMがこのDockerスキルを使用する際の参考プロンプトです。

## プロンプト例1: 基本的な使用

```
このDockerスキルを使ってデータ処理を実行してください。

Docker Image: ghcr.io/senna46/d6e-test-docker-skill:latest

このスキルは以下の操作をサポートしています：
- operation: "test" - 基本的な入出力テスト
- operation: "sql_select" - SQL SELECTクエリの実行
- operation: "sql_insert" - SQL INSERTの実行
- operation: "sql_update" - SQL UPDATEの実行

まずSTFを作成し、ワークフローを実行してください。
```

## プロンプト例2: データベース操作

```
test_dataテーブルからデータを取得してください。

使用するスキル:
- Docker Image: ghcr.io/senna46/d6e-test-docker-skill:latest
- Operation: sql_select
- Table: test_data

手順:
1. STFを作成（runtime: "docker", image: "ghcr.io/senna46/d6e-test-docker-skill:latest"）
2. ワークフローを作成
3. operation: "sql_select", table_name: "test_data" で実行
```

## プロンプト例3: 新しいレコードの追加

```
test_dataテーブルに新しいレコードを追加してください。

データ:
- name: "Sample Data"
- value: 999

使用するスキル:
- Docker Image: ghcr.io/senna46/d6e-test-docker-skill:latest
- Operation: sql_insert

必要な準備:
1. test_dataテーブルが存在すること
2. INSERTポリシーが設定されていること

手順:
1. 必要に応じてテーブルとポリシーを作成
2. STFとワークフローを作成
3. operation: "sql_insert" で実行
```

## LLMが理解すべき重要なポイント

### 1. STF作成時の設定

```javascript
{
  "runtime": "docker",  // 必須: dockerを指定
  "code": "{\"image\":\"ghcr.io/senna46/d6e-test-docker-skill:latest\"}"  // JSON文字列
}
```

### 2. 入力パラメータの構造

```javascript
{
  "operation": "test" | "sql_select" | "sql_insert" | "sql_update" | "error",
  // sql_select の場合
  "table_name": "テーブル名",
  // sql_insert の場合
  "table_name": "テーブル名",
  "data": {
    "column1": "value1",
    "column2": "value2"
  },
  // sql_update の場合
  "table_name": "テーブル名",
  "set": {
    "column1": "new_value"
  },
  "where": "id = 'xxx'"
}
```

### 3. 出力形式

成功時:
```json
{
  "output": {
    "status": "success",
    "operation": "sql_select",
    "rows": [...],
    "count": 3
  }
}
```

エラー時:
```json
{
  "output": {
    "status": "error",
    "error": "エラーメッセージ"
  }
}
```

### 4. SQL操作の前提条件

- **テーブルの存在**: `d6e_sql`でテーブルを作成
- **ポリシーの設定**: `d6e_create_policy_group`, `d6e_create_policy`でアクセス許可

### 5. 典型的なワークフロー

```
1. テーブル作成（必要な場合）
   d6e_sql({"sql": "CREATE TABLE ..."})

2. ポリシー設定（必要な場合）
   d6e_create_policy_group() → d6e_add_member_to_policy_group() → d6e_create_policy()

3. STF作成
   d6e_create_stf() → d6e_create_stf_version(runtime: "docker", image: "...")

4. ワークフロー作成・実行
   d6e_create_workflow() → d6e_execute_workflow()
```

## エラーハンドリング

LLMは以下のエラーに対処できる必要があります：

1. **テーブルが存在しない**
   - エラーメッセージに"does not exist"が含まれる
   - 対処: `d6e_sql`でテーブルを作成

2. **ポリシー拒否**
   - エラーメッセージに"Policy denied"が含まれる
   - 対処: ポリシーグループとポリシーを作成

3. **DDL禁止**
   - Docker STFからはCREATE/ALTER/DROPは実行不可
   - 対処: `d6e_sql`を直接使用

4. **無効な操作**
   - 対処: サポートされている操作（test, sql_select, sql_insert, sql_update）を使用

## ベストプラクティス

1. **段階的な実行**: まず"test"操作で動作確認
2. **明示的なエラーチェック**: 各ステップの結果を確認
3. **適切なポリシー設定**: 最小限の権限で運用
4. **ログの確認**: APIサーバーのログで詳細を確認

## 完全な実行例

```javascript
// ステップ1: テーブル作成
d6e_sql({
  "sql": "CREATE TABLE test_data (id UUID PRIMARY KEY DEFAULT uuidv7(), name TEXT, value INTEGER, created_at TIMESTAMPTZ DEFAULT NOW())"
})

// ステップ2: テストデータ挿入
d6e_sql({
  "sql": "INSERT INTO test_data (name, value) VALUES ('Test 1', 100), ('Test 2', 200)"
})

// ステップ3: STF作成
const stf = d6e_create_stf({
  "name": "test-docker-skill",
  "description": "Docker test skill"
})

// ステップ4: STFバージョン作成
d6e_create_stf_version({
  "stf_id": stf.id,
  "version": "1.0.0",
  "runtime": "docker",
  "code": "{\"image\":\"ghcr.io/senna46/d6e-test-docker-skill:latest\"}"
})

// ステップ5: ポリシーグループ作成
const policyGroup = d6e_create_policy_group({
  "name": "docker-test-group"
})

// ステップ6: STFをポリシーグループに追加
d6e_add_member_to_policy_group({
  "policy_group_id": policyGroup.id,
  "member_type": "stf",
  "member_id": stf.id
})

// ステップ7: SELECTポリシー作成
d6e_create_policy({
  "policy_group_id": policyGroup.id,
  "table_name": "test_data",
  "operation": "select",
  "mode": "allow"
})

// ステップ8: ワークフロー作成
const workflow = d6e_create_workflow({
  "name": "test-workflow",
  "stf_steps": [{"stf_id": stf.id, "version": "1.0.0"}]
})

// ステップ9: 実行
const result = d6e_execute_workflow({
  "workflow_id": workflow.id,
  "input": {
    "operation": "sql_select",
    "table_name": "test_data"
  }
})

// 結果確認
console.log(result) // {status: "success", rows: [...], count: 2}
```

このプロンプトとガイドラインに従うことで、LLMは効果的にこのDockerスキルを使用できます。
