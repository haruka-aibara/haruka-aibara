# Thinking Mode（Effort Level）

## こういうときに使いたい

「Claude に頼んだが、あっさりした回答で根拠が薄い」「複雑なバグの原因を深く追いかけてほしいのに、表面だけ見て答えを出してくる」。

普通のリクエストでは Claude は「それなりの深さ」で考える。もっと深く推論させたいとき、あるいは逆に単純な作業をコスト節約で素早く終わらせたいとき、**Effort Level** を使って思考量をコントロールできる。

---

## Effort Level とは

Claude が 1 回のリクエストにどれだけのトークン（思考量）を使うかを制御する設定。

Sonnet 4.6 と Opus 4.6 がサポート。デフォルトは **medium**。

| レベル | 特徴 |
|--------|------|
| `low` | 高速・低コスト。単純な作業向け |
| `medium` | デフォルト。速度と深さのバランス |
| `high` | 複雑なデバッグ・アーキテクチャ設計向け |
| `max` | Opus 4.6 のみ。思考トークン上限なし。深い問題向け |

---

## 使い方

### セッション内でレベルを変える

```
/effort high
```

以降のリクエスト全体に適用される。元に戻すには `/effort medium`。

### その 1 ターンだけ深く考えさせる

プロンプトに **`ultrathink`** を含めると、セッション設定を変えずにそのリクエストだけ `high` 相当の思考が発動する。

```
このアーキテクチャ設計の問題点を ultrathink で洗い出して
```

### 起動時にデフォルトを変える

```bash
claude --effort high
```

または環境変数で：

```bash
export CLAUDE_CODE_EFFORT_LEVEL=high
```

### settings.json で固定する

```json
{
  "effortLevel": "low"
}
```

---

## どのレベルをいつ使うか

**`low` を使う場面**
- 単純なコード補完・フォーマット
- CI での軽いチェック
- Haiku と組み合わせてコスト最小化

**`high` / `max` を使う場面**
- 再現しにくいバグの根本原因を追う
- 大規模リファクタリングの影響範囲を分析
- セキュリティ脆弱性の深い調査
- 複数システムにまたがる設計の検討

---

## コストへの影響

thinking トークンは **output トークンとして課金される**。`high` / `max` は回答 1 件あたりのトークン数が大幅に増える。

コストを抑えるには：
- 日常の作業は `medium`（デフォルト）のまま
- 難しいときだけ `ultrathink` を使う
- `max` は本当に詰まったときの切り札

---

## 参考

- [Adjust effort level - Claude Code Docs](https://code.claude.com/docs/en/model-config#adjust-effort-level)
- [Reduce token usage - Claude Code Docs](https://code.claude.com/docs/en/costs#reduce-token-usage)
