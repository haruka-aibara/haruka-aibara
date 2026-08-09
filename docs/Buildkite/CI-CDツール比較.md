# Buildkite：CI/CDツール比較

## どういうときに Buildkite が話題になるか

GitHub Actions や CircleCI で大規模なビルドを回していると、いくつかの壁にぶつかる。

- 同時実行数の上限がプランで決まっていて、スパイク時にキューが詰まる
- セキュリティポリシー上、ビルドをクラウドのランナーに乗せられない（コードやシークレットを外に出したくない）
- モノレポのビルド時間が肥大化して、何を変えてもフルビルドが走る

こういった場面で名前が出てくるのが Buildkite。

---

## Buildkite のアーキテクチャ

Buildkite は **ハイブリッド型**のCI/CDツール。

```
[Buildkite SaaS（制御プレーン）]
        ↑ HTTPS ポーリング
[自分のインフラで動かすエージェント]
        ↓
[実際のビルド実行]
```

- **制御プレーン**はBuildkite側のSaaSが担当（パイプラインの管理・スケジューリング・ログ収集）
- **エージェント**は自分のインフラで動かす。エージェントがBuildkiteのAgent APIをHTTPSでポーリングしてジョブを取得、完了後に結果を返す

エージェントが**アウトバウンドのHTTPS通信しかしない**ため、インフラ側のインバウンドポートを開ける必要がない。VPCの外にコードが出ず、シークレットも自分のネットワーク内で完結する。

---

## 他のツールとの比較

### 同時実行とスケール

| ツール | 同時実行の制限 |
|---|---|
| GitHub Actions | プラン依存（Free: 20並列、有料でも上限あり） |
| CircleCI | プラン依存（コンテナ数で課金） |
| GitLab CI | SaaS版はプラン依存・セルフホストは自前リソース次第 |
| Jenkins | セルフホストのリソース次第 |
| **Buildkite** | **エージェント数に人工的な上限なし**（10万並列の実績あり） |

Buildkite は「並列数の上限」という概念がない。エージェントを増やせばそのままスケールする。

### セキュリティモデル

| ツール | コードの置き場 | シークレットの扱い |
|---|---|---|
| GitHub Actions | GitHubのランナー（または self-hosted） | GitHub Secrets（GitHubに保存） |
| CircleCI | CircleCIのクラウド（または self-hosted） | CircleCIに保存 |
| GitLab CI | GitLab Shared Runners（または self-hosted） | GitLab CI/CDに保存 |
| Jenkins | セルフホスト | Credentials Plugin等で自己管理 |
| **Buildkite** | **エージェントは自前インフラ** | **シークレットは自分の環境のみ** |

Buildkite はビルドのコードもシークレットもエージェント側（自分のインフラ）にとどまる。コンプライアンス要件が厳しい環境で採用されやすい理由がここにある。

### パイプライン設定

| ツール | 設定形式 |
|---|---|
| GitHub Actions | YAML（`.github/workflows/`） |
| CircleCI | YAML（`.circleci/config.yml`） |
| GitLab CI | YAML（`.gitlab-ci.yml`） |
| Jenkins | Groovy（Jenkinsfile） |
| **Buildkite** | **YAML（`.buildkite/pipeline.yml`）または SDK（コード）** |

Buildkite の特徴は「パイプラインがビルド中に自分自身を変更できる」点。実行時にステップを動的に追加・変更できるため、変更されたファイルに応じて実行内容を切り替えるようなダイナミックなパイプラインが書ける。

例：モノレポで変更があったサービスだけビルドする

```yaml
# .buildkite/pipeline.yml
steps:
  - label: "パイプラインを生成"
    command: ".buildkite/generate-pipeline.sh | buildkite-agent pipeline upload"
```

`generate-pipeline.sh` の中でどのサービスが変更されたかを判定し、必要なステップだけをアップロードする。

### モノレポ対応

| ツール | モノレポ対応 |
|---|---|
| GitHub Actions | `paths` フィルターで部分実行可（ジョブ単位） |
| CircleCI | Dynamic Config で実現可能 |
| GitLab CI | `rules: changes` で部分実行 |
| Jenkins | プラグインやスクリプトで自前実装が多い |
| **Buildkite** | **ネイティブに動的パイプライン生成をサポート** |

Buildkite は「変更されたファイルに応じてパイプラインをビルド時に動的生成する」パターンが設計思想レベルで組み込まれている。

---

## Buildkite のステップ種類

```yaml
steps:
  # コマンドステップ（ビルド・テスト・デプロイの実行）
  - label: "テスト"
    command: "pytest"

  # ウェイトステップ（前のステップが全部完了するまで待つ）
  - wait

  # ブロックステップ（手動承認が必要なゲート）
  - block: "本番へのデプロイを承認"

  # トリガーステップ（別のパイプラインを呼び出す）
  - trigger: "deploy-production"
    label: "本番デプロイを起動"
```

GitHub Actions の `environment: production` による承認フローに相当するのが `block` ステップ。

---

## エージェントのキューとルーティング

エージェントにタグを付けて、ジョブを特定のエージェントプールに振り分けられる。

```bash
# GPU が必要なビルド用エージェントを起動
buildkite-agent start --tags "queue=gpu,os=linux"
```

```yaml
# pipeline.yml 側でキューを指定
steps:
  - label: "モデル学習"
    command: "python train.py"
    agents:
      queue: gpu
```

「社内の特定サーバーでしか動かせない処理がある」という要件に対して、キューで明示的にルーティングできる。

---

## 料金モデル

| プラン | 月額 | 特徴 |
|---|---|---|
| Personal | 無料 | 同時実行3・ユーザー1・90日データ保持 |
| Pro | $30/アクティブユーザー | 無制限ユーザー・優先サポート |
| Enterprise | 要問い合わせ（30ユーザー〜） | SCIM/SAML・高度な権限管理 |

**セルフホストエージェントは無制限・追加料金なし**。エージェントを100台動かしてもエージェント分の課金は発生しない（自分のインフラコストのみ）。

Buildkite ホスト型エージェントを使う場合はコンピューティング分の従量課金（例：Small $0.013/分）。

---

## どのツールを選ぶか

### GitHub Actions で十分なケース

- GitHub でコードを管理している
- チームが小規模で並列数の上限に当たらない
- シークレットをGitHubに置いてもコンプライアンス上問題ない

### Buildkite が適するケース

- ビルドのスパイク時に並列数の上限で詰まっている
- セキュリティポリシー上、ビルドをサードパーティのランナーで走らせられない（金融・医療・防衛など）
- モノレポで「変更されたサービスだけビルド」を柔軟に制御したい
- ビルドインフラを既に持っていて、それを最大限活かしたい

### Jenkins からの移行先として

Jenkinsの課題（Groovy習得コスト・プラグイン管理・UIの古さ）を解決しつつ、セルフホストの柔軟性を維持したいチームにとってBuildkiteは有力な選択肢。Jenkins Pipelineの「コードでパイプラインを書く」思想を継承しながら、スケール・UIの面でモダン化できる。

---

## 参考

- [Buildkite Documentation](https://buildkite.com/docs)
- [Buildkite Agent Overview](https://buildkite.com/docs/agent/v3)
- [Buildkite Pricing](https://buildkite.com/pricing)
- [Dynamic Pipelines](https://buildkite.com/docs/pipelines/dynamic-pipelines)
- [Buildkite vs. Other CI/CD Tools](https://buildkite.com/features)
