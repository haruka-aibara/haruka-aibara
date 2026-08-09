# セキュリティ機能開発を AI に任せて、人間は承認だけにできるか

AI コーディングエージェントが実用レベルになり、「セキュリティ機能の開発も AI に任せて、人間は承認だけすればいい状態にできないか」と問われる場面が増えている。エンタープライズ環境で、サンドボックスアカウントもある。技術的には全部揃っているように見える。

結論を先に言う。**条件付きで成立する。ただし成立させるのは「AI への信頼」ではなく「構造」だ。** そして一番設計が難しいのは AI 側ではなく、**「人間の承認」を意味のある行為として維持する側**にある。

---

## 発想の転換：「AI を信頼できるか」は問いとして間違っている

「AI が安全なコードを書けるか」を出発点にすると、答えは永遠に出ない。Veracode の 2025 年調査では AI 生成コードの 45% にセキュリティ脆弱性が含まれていた。モデルが進化しても、プロンプトインジェクションで意図を汚染されるリスクは残る。OWASP の Agentic Applications Top 10（2026）が筆頭に挙げるのも、ゴールハイジャックと過剰な権限（Excessive Agency）の組み合わせだ。

だから問いを変える。**「AI が悪意を持って（あるいは騙されて）最悪の行動をしたとき、何が壊れるか」を出発点にする。** 壊れる範囲が構造的に制限されていれば、AI の内心を信頼する必要がなくなる。これは新しい考え方ではない。信頼できない実行主体を封じ込めるという意味で、やることはマルウェアサンドボックスや最小権限設計と同じだ。相手が AI になっただけで、クラウドセキュリティエンジニアが既に持っている道具で戦える。

以下、その構造を 5 つの層に分けて設計する。

---

## Layer 0：アカウント分離 — サンドボックスを「信頼境界」として使う

エンタープライズで AWS Organizations / Control Tower が入っているなら、最初の武器はこれだ。**IAM の信頼境界はアカウントである。** サンドボックスアカウント内で AI が Administrator 相当を持っていても、本番アカウントの API は一切呼べない。

設計のポイント：

- **AI 専用のサンドボックス OU を切る**。人間の実験用サンドボックスと混ぜない。適用する SCP・監視レベル・掃除ポリシーが違うから
- **SCP で「何があっても越えられない天井」を定義する**。組織外への AMI/スナップショット共有の禁止、リージョン制限、`organizations:*`・`account:*` の拒否、CloudTrail 停止の拒否など
- **コストの上限を機械で切る**。AI は人間と違って 24 時間リソースを作り続けられる。予算アラートではなく、閾値超過で自動停止まで入れる
- **定期的に自動で更地に戻す**（aws-nuke 等）。AI が作った検証リソースの残骸は、人間のそれより速く溜まる

ここで重要なのは、**サンドボックスは「AI が自由にやっていい場所」ではなく「AI の失敗を吸収する場所」として設計する**ことだ。目的が違うと SCP の書き方が変わる。

## Layer 1：AI の実行環境 — 認証情報とネットワークを絞る

AI エージェント本体（Claude Code、Amazon Q Developer 等）が動く環境の統制。ここは 2025〜2026 年に実際のインシデント・脆弱性報告が集中している場所だ。

- **長期認証情報を渡さない**。CI 上で動かすなら OIDC フェデレーションで短命トークンを取得する。エージェントに `AWS_SECRET_ACCESS_KEY` を環境変数で渡す構成は論外
- **実行ロールに Permissions Boundary を付ける**。AI が IAM ロールを作成できる必要がある場合（セキュリティ機能開発では頻出）、Boundary なしのロール作成を IAM ポリシーの Condition で拒否する。これで「AI が自分より強い権限を作る」経路を塞げる
- **アウトバウンド通信を制限する**。エージェントのランナーからの egress を許可リスト制にする。プロンプトインジェクションで機密情報を外部送信させる攻撃の出口対策になる。Microsoft が 2026 年に報告した Claude Code GitHub Action の事例は、まさに「信頼できないコンテンツ（Issue 本文等）を AI が処理して CI シークレットが漏れる」経路だった
- **AI が読むコンテンツは汚染されている前提で扱う**。Issue、PR コメント、外部ドキュメントは全て攻撃者が書ける場所。エージェントの指示（システムプロンプト・タスク定義）と、エージェントが参照するデータを分離し、後者からの指示は実行しない構成にする

## Layer 2：機械のゲート — 人間より先に決定論的チェックを置く

人間の承認の前に、決定論的に動くゲートを全部通す。人間に「lint で見つかるレベルの問題」を見させたら、その時点で承認は形骸化に向かう。

セキュリティ機能開発（IaC が中心になる）なら：

| ゲート | ツール例 | 落ちたら |
|---|---|---|
| シークレット混入 | gitleaks | 必ずブロック |
| IaC ミスコンフィグ | Trivy config / Checkov | HIGH 以上ブロック |
| IAM ポリシーの妥当性 | IAM Access Analyzer（ポリシー検証・カスタムチェック） | 過剰権限・public 化をブロック |
| 組織ポリシー準拠 | OPA / cfn-guard によるポリシー・アズ・コード | 必ずブロック |
| テスト | 単体・結合＋カバレッジ閾値 | 必ずブロック |
| plan 差分の危険操作 | terraform plan の delete/replace 検出 | 検出時は人間承認へ昇格 |

ここで一つ、AI 時代特有の罠がある。**AI がコードもテストも両方書くと、同じ解釈ミスをしたテストでゲートが通る。** テストが通った＝仕様通り、ではない。対策は Layer 4（検証の独立性）で扱う。

## Layer 3：昇格経路の一本化 — AI は本番に「触れない」のではなく「触る経路が存在しない」

サンドボックスで開発した機能を本番に出す経路を、物理的に 1 本にする。

- **AI は PR を作るところまで**。マージとデプロイの権限を持たない。ブランチ保護＋CODEOWNERS で強制する
- **デプロイできるのはパイプラインのロールだけ**。人間も AI も本番アカウントに直接デプロイできない。承認済みのパイプライン実行だけが本番に到達する
- **成果物に来歴（provenance）を付ける**。どのコミットから、どのパイプラインで、どのゲートを通ってビルドされたかを署名付きで記録する（SLSA / GitHub Artifact Attestations）。デプロイ側で検証し、「ゲートを通っていない成果物」は本番に入れない

この構成なら、AI がプロンプトインジェクションで完全に乗っ取られても、できることは「怪しい PR を作る」まで。それはゲートと承認で止める前提の設計になっている。

## Layer 4：デプロイ後 — 「承認したから安心」で終わらせない

承認は事前の統制であり、事後の検知とロールバックが対になって初めて「安心して承認できる」。

- **段階的リリース**。検知ルールや自動修復（auto-remediation）のような「自分で動くセキュリティ機能」は、まず検知のみモード（learn mode）で本番投入し、誤検知率を確認してから enforce に昇格させる。AI が書いた自動修復がいきなり enforce で動くのは、AI が本番を直接触るのと変わらない
- **自動ロールバック**。デプロイ後のアラーム連動でロールバックする。CodeDeploy/CloudFormation のロールバックトリガーでよい
- **AI の挙動自体を監視対象にする**。AI 実行ロールの CloudTrail イベントは通常の開発者と別のベースラインで見る。GuardDuty・Security Hub のアラート対象に「AI が想定外の API を呼んだ」を含める

---

## 本題：「人間は承認だけ」を成立させる設計

ここまでは技術で解ける。難しいのはここからだ。

**承認だけを仕事にした人間は、承認しなくなる。** 正確には、見ずに承認するようになる。自動化バイアスの研究が一貫して示している通り、信頼できるシステムの出力を毎回精査し続けることは人間にはできない。承認キューが溜まれば一括承認が始まり、その瞬間に「人間の承認」という統制は監査上の見せかけ（rubber stamp）になる。

これを防ぐ設計が 4 つある。

### 1. 承認者に diff ではなく「証拠パッケージ」を見せる

AI が書いた 2,000 行の Terraform diff を人間が精査するのは無理だし、それは Layer 2 の機械の仕事だ。人間が見るべきは：

- **何を・なぜ変えるのか**（意図。元の要求とのトレーサビリティ）
- **どのゲートを通ったか**（全ゲートの結果一覧）
- **壊れたときの影響範囲**（このロールが漏れたら何ができるか、この検知ルールが誤動作したら何が止まるか）
- **戻し方**（ロールバック手段が存在し、テスト済みか）

この 4 点を AI 自身にまとめさせ、機械ゲートで裏を取る。人間の承認は「コードレビュー」ではなく「リスク引き受けの判断」に再定義する。

### 2. リスクベースで承認を絞る — 全部承認は全部ノールックと同じ

全変更に人間の承認を要求すると、承認の価値が薄まる。逆に絞る。

| リスク | 例 | 承認 |
|---|---|---|
| 低 | 検知ルールの閾値調整、タグ付与、learn mode の新ルール | ゲート通過で自動マージ |
| 中 | 新しい検知機能、Lambda の追加、読み取り権限の追加 | 人間 1 名の承認 |
| 高 | IAM 書き込み権限、SCP・ガードレールの変更、enforce モードの自動修復、検知ルールの無効化 | 人間 2 名以上＋変更管理プロセス |

「人間は承認だけすればよい」は、正しくは「**人間はリスクの高い変更の承認だけすればよい**」になる。承認件数が減るほど 1 件あたりの注意量は上がる。

### 3. AI に「自分の檻」を触らせない

セキュリティ機能開発を AI に任せるとき特有の急所がここだ。開発対象（検知ルール、IAM、SCP、パイプライン定義）と、AI を統制している仕組みが**同じ技術スタック上にある**。放っておくと「AI が自分のガードレールを緩める PR を作り、それが低リスク扱いで自動マージされる」構造ができあがる。

- SCP・Permissions Boundary・パイプライン定義・ブランチ保護設定・機械ゲートの設定は**統制プレーン**として別リポジトリ／別アカウントに分離し、AI の書き込み経路から外す
- AI が触れるのは「統制の下にある開発対象」だけ。「統制そのもの」は人間が管理する
- これは職務分離（Separation of Duties）そのもの。監査対応でもこの整理がそのまま使える

### 4. 承認という統制を、統制としてテストする

ガードレールは作った瞬間から劣化する。定期的に検証する。

- **抜き打ちテスト**：意図的に問題のある変更（過剰権限の IAM、検知ルールの無効化）を承認フローに流し、止まるかを確認する。フィッシング訓練の承認版
- **承認ログの監査**：承認までの所要時間が数秒に張り付いていたら、それはもう見ていない
- **AI 自身にレッドチームをさせる**：サンドボックスがあるのだから、「このガードレール構成を突破する方法を探せ」というタスクを別の AI エージェントに与えて、構造の穴を先に見つける

---

## セキュリティ機能ならではの検証問題

もう一つ、対象がセキュリティ機能であることから来る固有の難しさがある。**セキュリティ機能は正常系では発火しない。** 検知ルールが正しいかは、攻撃が来るまで分からない——では困る。

- 検知ルールは**攻撃シミュレーションとセットで納品させる**。GuardDuty のサンプル検出、Security Hub へのテストイベント投入、Atomic Red Team 的な安全な攻撃再現をサンドボックスで実行し、「検知した証拠」を証拠パッケージに含める
- **検証は生成と独立させる**。実装した AI と同じコンテキストの AI がテストを書くと、同じ解釈ミスがテストにも入る。仕様（何を検知すべきか）は人間または別系統が定義し、実装がそれを満たすかを検証する構造にする

「AI がテストも書いて全部グリーンです」を承認の根拠にしない。**発火する証拠**を根拠にする。

---

## 正直な結論：「完全に安心」の中身

「完全自律の AI 開発＋人間は承認のみ」は、以下がすべて揃えば実用として成立する。

1. アカウント分離と SCP で、AI の最悪ケースの被害範囲が定義済み（Layer 0）
2. 短命credential・egress 制御・汚染前提の入力処理（Layer 1）
3. 人間の前に決定論的ゲート（Layer 2）
4. 本番への経路がパイプライン 1 本で、来歴検証付き（Layer 3）
5. 段階的リリースと自動ロールバック（Layer 4）
6. 承認がリスクベースで絞られ、証拠パッケージ化され、定期監査されている
7. AI が自分の統制を変更できない職務分離がある

ただし「完全に安心」の意味は正確に理解しておく必要がある。これは「AI が間違えない」保証ではなく、**「AI が間違えても、事前に合意した範囲を超えて壊れない」保証**だ。残余リスクは残る：プロンプトインジェクションによる意図の汚染、承認の形骸化、仕様解釈のズレ、そして統制自体のバグ。だから人間の仕事はなくならない。**コードを書く仕事から、AI が壊せる範囲の境界を設計・維持・検証する仕事に移る。** それはまさにセキュリティエンジニアリングそのものだ。

### ビジネス側への言語化

| 技術的な言い方 | ビジネス側に刺さる言い方 |
|---|---|
| AI 専用サンドボックスと SCP を整備する | AI に開発を任せても、事故の最大被害額と範囲を事前に確定できる |
| 承認をリスクベースに絞る | 人間の判断を「全件チェック係」から「重要案件の意思決定」に集中させ、開発速度と統制を両立する |
| 統制プレーンを分離する | 「AI が自分のルールを書き換えられない」ことを監査に対して構造で説明できる |
| 承認フローの抜き打ちテストをする | 「承認しているから大丈夫」が本当かを、事故の前に確認できる |

---

## 参考

- [AWS Cloud Operations Blog: Best practices for creating and managing sandbox accounts in AWS](https://aws.amazon.com/blogs/mt/best-practices-creating-managing-sandbox-accounts-aws/)
- [AWS Organizations: Service control policies (SCPs)](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html)
- [AWS Workshop: Controlling Builder Team Access to Development Environments（Permissions Boundary の配布パターン）](https://getstarted.awsworkshop.io/01-dev/03-reference/02-controlling-builder-team-access.html)
- [AWS Security Blog: Secure AI agent access patterns to AWS resources using Model Context Protocol](https://aws.amazon.com/blogs/security/secure-ai-agent-access-patterns-to-aws-resources-using-model-context-protocol/)
- [OWASP Gen AI Security Project: Top 10 for Agentic Applications for 2026](https://genai.owasp.org/resource/owasp-top-10-for-agentic-applications-for-2026/)
- [Microsoft Security Blog: Securing CI/CD in an agentic world — Claude Code GitHub Action case](https://www.microsoft.com/en-us/security/blog/2026/06/05/securing-ci-cd-in-agentic-world-claude-code-github-action-case/)
- [Claude Code Docs: GitHub Actions](https://code.claude.com/docs/en/github-actions)
- [StepSecurity: How to Secure Claude Code in GitHub Actions with Harden-Runner](https://www.stepsecurity.io/blog/anthropics-claude-code-action-security-how-to-secure-claude-code-in-github-actions-with-harden-runner)
- [SLSA: Supply-chain Levels for Software Artifacts](https://slsa.dev/)
- [Legit Security: Deep Dive Into SLSA Provenance and Software Attestation](https://www.legitsecurity.com/blog/slsa-provenance-blog-series-part-2-deeper-dive-into-slsa-provenance)
- [TechTarget: Human-in-the-loop shouldn't rubber-stamp decisions](https://www.techtarget.com/searchcio/feature/Human-in-the-loop-shouldnt-rubber-stamp-decisions)
- [MIT Sloan Management Review: AI Explainability — How to Avoid Rubber-Stamping Recommendations](https://sloanreview.mit.edu/article/ai-explainability-how-to-avoid-rubber-stamping-recommendations/)
- [Institute for Systems Integrity: From Human-in-the-Loop to Human-with-Agency](https://www.systemsintegrity.org/from-human-in-the-loop-to-human-with-agency-why-ai-oversight-fails-when-humans-are-present-but-powerless/)
- [Veracode: 2025 GenAI Code Security Report](https://www.veracode.com/resources/analyst-reports/2025-genai-code-security-report/)
- [IAM Access Analyzer: ポリシー検証](https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-policy-validation.html)
