# クイックスタートガイド

D6E Docker Runtime の機能テストを 5 分で開始できます。

## ステップ 1: Docker イメージのビルド（1 分）

```bash
cd ~/github.com/Senna46/d6e-test-docker-skill
./test-local.sh
```

これでローカルテストが完了し、イメージがビルドされます。

## ステップ 2: D6E サーバーの起動（1 分）

```bash
cd /home/user/github.com/KimuraYu45z/d6e
docker compose -f compose.withdb.yml up -d
```

サーバーが起動するまで待ちます：

```bash
# ヘルスチェック
curl http://localhost:8080/health
# 200 OKが返ればOK
```

## ステップ 3: ワークスペースとテーブルの準備（1 分）

1. ブラウザで http://localhost:3000 を開く
2. ユーザー登録/ログイン
3. ワークスペースを作成

MCP ツールまたはフロントエンドで以下を実行：

```sql
CREATE TABLE test_data (
  id UUID PRIMARY KEY DEFAULT uuidv7(),
  name TEXT NOT NULL,
  value INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO test_data (name, value) VALUES
  ('Test 1', 100),
  ('Test 2', 200),
  ('Test 3', 300);
```

## ステップ 4: STF とポリシーの作成（2 分）

以下のコマンドを MCP ツール（Cursor AI など）で実行：

```javascript
// 1. STFを作成
d6e_create_stf({
  name: "test-docker-skill",
  description: "Docker STF test",
});
// → stf_id をメモ

// 2. STFバージョンを作成
d6e_create_stf_version({
  stf_id: "{上記のstf_id}",
  version: "1.0.0",
  runtime: "docker",
  code: '{"image":"d6e-test-skill:latest"}',
});

// 3. ポリシーグループを作成
d6e_create_policy_group({
  name: "docker-test-group",
});
// → policy_group_id をメモ

// 4. STFをポリシーグループに追加
d6e_add_member_to_policy_group({
  policy_group_id: "{上記のpolicy_group_id}",
  member_type: "stf",
  member_id: "{stf_id}",
});

// 5. ポリシーを作成（select, insert, update）
d6e_create_policy({
  policy_group_id: "{policy_group_id}",
  table_name: "test_data",
  operation: "select",
  mode: "allow",
});

d6e_create_policy({
  policy_group_id: "{policy_group_id}",
  table_name: "test_data",
  operation: "insert",
  mode: "allow",
});

d6e_create_policy({
  policy_group_id: "{policy_group_id}",
  table_name: "test_data",
  operation: "update",
  mode: "allow",
});

// 6. ワークフローを作成
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
// → workflow_id をメモ
```

## ステップ 5: テスト実行！

```javascript
// 基本テスト
d6e_execute_workflow({
  workflow_id: "{workflow_id}",
  input: {
    operation: "test",
  },
});

// SQL SELECTテスト
d6e_execute_workflow({
  workflow_id: "{workflow_id}",
  input: {
    operation: "sql_select",
    table_name: "test_data",
  },
});

// SQL INSERTテスト
d6e_execute_workflow({
  workflow_id: "{workflow_id}",
  input: {
    operation: "sql_insert",
    table_name: "test_data",
    data: {
      name: "New Test",
      value: 999,
    },
  },
});
```

## 成功！

すべてのテストが成功したら、Docker Runtime 機能は正常に動作しています！🎉

## 詳細なテスト手順

より詳細なテスト手順は以下を参照：

- `TESTING.md` - ステップバイステップの詳細ガイド
- `/home/user/github.com/KimuraYu45z/d6e/docs/09-testing-docker-runtime.md` - 完全なテストドキュメント

## トラブルシューティング

### Docker イメージが見つからない

```bash
# ホストでイメージを確認
docker images | grep d6e-test-skill

# なければ再ビルド
make build
```

### SQL 実行エラー

ポリシーが正しく設定されているか確認：

```javascript
d6e_list_policies({
  policy_group_id: "{policy_group_id}",
});
```

### ログ確認

```bash
docker logs d6e-api-1 -f
```

## 次のステップ

1. 他の操作（UPDATE、DELETE）をテスト
2. エラーハンドリングをテスト
3. 独自の Docker Skill を作成
4. 本番環境への展開

Happy Testing! 🚀
