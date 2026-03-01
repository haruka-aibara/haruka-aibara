<!-- Space: harukaaibarapublic -->
<!-- Parent: スライド作成 -->
<!-- Title: AI でスライドを作る（ツール比較） -->

# AI でスライドを作る（ツール比較）

「プレゼン資料を作る」といっても、目的によって最適なツールが変わる。まず自分のユースケースを確認する。

---

## どのツールを使うべきか

| やりたいこと | 最適なツール |
|---|---|
| とにかく速くきれいなスライドが欲しい | **Gamma.app** |
| PowerPoint に Claude を組み込んで使いたい | **Claude in PowerPoint**（アドイン） |
| Claude.ai のチャットから PPTX を生成したい | **Claude.ai**（Max/Teams/Enterprise） |
| コードや CI/CD からパワポを自動生成したい | **claude-office-skills**（Claude Code） |
| Python でプログラム制御したい | **python-pptx + Claude API** |

---

## Gamma.app ── 一番手軽

テキストを入力するだけで、デザインされたスライドが数十秒で生成される。日本語対応、無料から使える。

**フロー:** プロンプト入力 → 枚数・スタイル選択 → AI 生成 → 手直し → エクスポート（PDF/PPTX/PNG）

**向いている用途:** 社外プレゼン、LT スライド、提案資料のたたき台

→ 詳細: [Gamma.md](Gamma.md)

---

## Claude in PowerPoint ── Microsoft 環境の人向け

PowerPoint のアドイン（Microsoft AppSource）として Claude が使えるようになった。既存テンプレートのフォント・レイアウトを読み取った上でスライドを生成・編集するので、ブランドから外れない。

**対象:** Claude Pro / Max / Team / Enterprise サブスクライバー（2025年末時点 Research Preview）

**できること:**
- 「このトピックでスライドを 5 枚作って」
- 「箇条書きをもっと簡潔にして」
- 「このスライドにグラフを追加して」

---

## Claude.ai ── チャットから PPTX を直接生成

Claude.ai（Max/Teams/Enterprise プラン）では、チャットの中で「プレゼン資料を作って」と頼むと PPTX ファイルが生成されてダウンロードできる。内部で python-pptx を動かしている。

```
プロンプト例:
「AWS のセキュリティベストプラクティスについて、
 エンジニア向けに 8 枚のプレゼンスライドを PPTX で作成してください。
 各スライドにスピーカーノートも入れてください。」
```

**向いている用途:** 手軽にパワポのたたき台を作って、あとは PowerPoint で仕上げる

→ 詳細: [Claudeでパワポ生成.md](Claudeでパワポ生成.md)

---

## claude-office-skills ── Claude Code から CLI で生成

Claude Code（CLI）向けに PPTX / DOCX / XLSX / PDF の生成スキルをまとめたリポジトリ。スクリプトや CI/CD パイプラインから自動生成したいときに使う。

```bash
# インストール
git clone https://github.com/tfriedel/claude-office-skills
```

スライドの HTML テンプレートを用意して Claude Code に渡すと PPTX に変換してくれる。定型レポートの自動化に向いている。

---

## python-pptx + Claude API ── 完全制御したい人向け

デザインの自由度は落ちるが、データから自動生成・大量生成するなら python-pptx 一択。Claude API でスライドの構造（タイトル・本文・ノート）を JSON で生成させ、python-pptx でファイル化する。

```python
# Claude API でスライド構造を生成 → python-pptx でファイル化
slides_json = claude.generate_slides(topic="AWS セキュリティ")
create_pptx(slides_json, template="company_template.pptx")
```

**向いている用途:** 月次レポートを自動生成、DB のデータをスライドに流し込む
