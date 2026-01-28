# AI エージェント用プロンプト（コピペ推奨）

このファイルには、AI エージェントに直接コピー&ペーストできるプロンプトが含まれています。

---

## 🚀 クイックスタート（最もシンプル）

```
Docker STF (ghcr.io/senna46/d6e-test-docker-skill:latest) を使って、test_dataテーブルからデータを取得してください。

必要に応じてテーブルとポリシーを作成してください。
```

---

## 📋 基本プロンプト（推奨）

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
4. d6e_execute_workflow で operation: "test" を実行して動作確認

サポートされている操作:
- "test": 基本動作確認
- "sql_select": データ取得（table_name必須）
- "sql_insert": データ挿入（table_name, data必須）
- "sql_update": データ更新（table_name, set必須）

まずは動作確認をしてください。
```

---

## 🗃️ SQL 操作プロンプト

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
   INSERT INTO test_data (name, value)
   VALUES ('Test 1', 100), ('Test 2', 200), ('Test 3', 300)

3. STF作成:
   - name: "test-docker-skill"
   - runtime: "docker"
   - code: "{\"image\":\"ghcr.io/senna46/d6e-test-docker-skill:latest\"}"

4. ポリシー設定:
   - ポリシーグループ作成（name: "docker-test-group"）
   - STFをグループに追加
   - SELECTポリシー作成（table: "test_data", operation: "select", mode: "allow"）

5. ワークフロー作成・実行:
   - name: "test-docker-workflow"
   - stf_steps: [{stf_id, version: "1.0.0"}]
   - 実行: operation: "sql_select", table_name: "test_data"

結果を表形式で表示してください。
```

---

## 📝 データ挿入プロンプト

```
test_dataテーブルに新しいレコードを追加してください。

Docker Image: ghcr.io/senna46/d6e-test-docker-skill:latest

データ:
- name: "AI Generated Record"
- value: 999

手順:
1. test_dataテーブルが存在することを確認（なければ作成）
2. INSERTポリシーが設定されていることを確認（なければ作成）
3. Docker STFを使用して以下で実行:
   - operation: "sql_insert"
   - table_name: "test_data"
   - data: {"name": "AI Generated Record", "value": 999}

挿入されたレコードを表示してください。
```

---

## 🔍 データ更新プロンプト

```
test_dataテーブルの特定レコードを更新してください。

Docker Image: ghcr.io/senna46/d6e-test-docker-skill:latest

更新内容:
- name が "Test 1" のレコードの value を 1000 に更新

手順:
1. UPDATEポリシーが設定されていることを確認
2. Docker STFで実行:
   - operation: "sql_update"
   - table_name: "test_data"
   - set: {"value": 1000}
   - where: "name = 'Test 1'"

更新後のデータを表示してください。
```

---

## 🛠️ トラブルシューティングプロンプト

```
Docker STFの動作を詳細にテストしてください。

Docker Image: ghcr.io/senna46/d6e-test-docker-skill:latest

テスト項目:
1. 基本動作テスト:
   - operation: "test"
   - 期待結果: status: "success"

2. 不明な操作テスト:
   - operation: "unknown"
   - 期待結果: status: "error", message: "Unknown operation"

3. エラーハンドリングテスト:
   - operation: "error"
   - 期待結果: エラーが適切に処理される

各テストの実行結果を報告してください。
エラーが発生した場合は、エラーメッセージと対処方法を提示してください。
```

---

## 📊 完全ワークフロープロンプト

```
Docker STFを使った完全なデータ操作ワークフローを実行してください。

Docker Image: ghcr.io/senna46/d6e-test-docker-skill:latest

ワークフロー:
1. 環境準備:
   - test_dataテーブル作成
   - 初期データ挿入（3件）
   - STF作成（runtime: "docker"）
   - ポリシー設定（SELECT, INSERT, UPDATE）
   - ワークフロー作成

2. 動作確認:
   - operation: "test" で基本動作確認

3. データ取得:
   - operation: "sql_select" で全データ取得
   - 結果を表形式で表示

4. データ追加:
   - operation: "sql_insert" で新規レコード追加
   - 追加後のデータを確認

5. データ更新:
   - operation: "sql_update" で既存レコード更新
   - 更新後のデータを確認

各ステップの実行結果を明示的に表示し、最終的な状態を確認してください。
```

---

## ⚠️ 重要な注意事項

コピペする際の注意:

- `runtime` は必ず `"docker"` を指定
- `code` フィールドは JSON 文字列として渡す: `"{\"image\":\"ghcr.io/senna46/d6e-test-docker-skill:latest\"}"`
- SQL 操作の前に必ずテーブルとポリシーを確認
- エラーが発生したら、エラーメッセージを読んで対処
- 初めて使う場合は `operation: "test"` で動作確認を推奨

---

## 📚 追加リソース

- 詳細ガイド: [README.md](./README.md)
- プロンプト例集: [LLM-PROMPT.md](./LLM-PROMPT.md)
- クイックスタート: [QUICKSTART.md](./QUICKSTART.md)
- GitHub: https://github.com/Senna46/d6e-test-docker-skill
