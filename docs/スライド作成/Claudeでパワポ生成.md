<!-- Space: harukaaibarapublic -->
<!-- Parent: スライド作成 -->
<!-- Title: Claude でパワポを生成する -->

# Claude でパワポを生成する

Claude には複数の方法でパワポを生成する機能がある。使えるプランと目的によって選ぶ。

---

## 方法1: Claude.ai チャットから PPTX を直接生成

**必要なプラン:** Max / Teams / Enterprise

Claude.ai のチャット上で「プレゼン資料を作って」と頼むと、内部で python-pptx を動かして PPTX ファイルを生成・ダウンロードできる。

**プロンプト例:**

```
AWS Well-Architected Framework の 6 本柱について、
社内勉強会向けの PowerPoint スライドを作成してください。

- 枚数: 8 枚（タイトル + 各柱 1 枚 + まとめ）
- 対象: インフラエンジニア（経験 2〜3 年程度）
- 各スライドにスピーカーノートを追加
- PPTX 形式で出力
```

**向いている用途:** たたき台を素早く作る。あとは PowerPoint で仕上げる。

---

## 方法2: Claude in PowerPoint（アドイン）

**必要なプラン:** Pro / Max / Teams / Enterprise（Research Preview）

Microsoft AppSource から「Claude」アドインをインストールすると、PowerPoint の作業ウィンドウで Claude が使える。

**特徴:**
- 既存テンプレートのフォント・レイアウトを読んでから生成するので、会社のスライドマスターを壊さない
- スライドを選択した状態で指示を出すと、そのスライドだけを編集できる
- 「この箇条書きを 3 行にまとめて」「このスライドに次のポイントを追加して」などのインライン編集が得意

**インストール:**
PowerPoint → 挿入 → アドイン → アドインを取得 → "Claude" で検索

---

## 方法3: Claude Code（CLI）＋ claude-office-skills

**必要なもの:** Claude Code + [tfriedel/claude-office-skills](https://github.com/tfriedel/claude-office-skills) リポジトリ

Claude Code で PPTX を生成するスキルを追加できる。スクリプトや CI/CD から自動生成したいときに使う。

```bash
# リポジトリを clone してスキルをセットアップ
git clone https://github.com/tfriedel/claude-office-skills

# Claude Code のプロジェクトディレクトリに SKILL.md を配置することで
# Claude Code が自動的にスキルを認識する
```

**できること:**
- HTML テンプレートを PPTX に変換
- 既存テンプレートにデータを流し込んでスライドを生成
- 生成後にサムネイルグリッドでレイアウト崩れを確認（バリデーション）
- PPTX / DOCX / XLSX / PDF に対応

**向いている用途:** 月次レポートの自動生成、データから定型スライドを量産

---

## 方法4: python-pptx + Claude API（フルコントロール）

完全に自動化したい・デザインをコードで制御したい場合。

```python
import anthropic
from pptx import Presentation
from pptx.util import Inches, Pt
import json

# 1. Claude API でスライド構造を生成
client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-opus-4-6",
    max_tokens=2000,
    messages=[{
        "role": "user",
        "content": """
            AWS GuardDuty の概要を説明する 5 枚のスライドを JSON で生成してください。
            形式:
            [
              {
                "title": "スライドタイトル",
                "bullets": ["箇条書き1", "箇条書き2"],
                "notes": "スピーカーノート"
              }
            ]
            JSON だけを返してください。
        """
    }]
)

slides_data = json.loads(response.content[0].text)

# 2. python-pptx でファイル生成
prs = Presentation()
prs.slide_width = Inches(13.33)
prs.slide_height = Inches(7.5)

for slide_data in slides_data:
    layout = prs.slide_layouts[1]  # タイトルと本文
    slide = prs.slides.add_slide(layout)

    slide.shapes.title.text = slide_data["title"]

    tf = slide.placeholders[1].text_frame
    tf.text = slide_data["bullets"][0]
    for bullet in slide_data["bullets"][1:]:
        p = tf.add_paragraph()
        p.text = bullet

    # スピーカーノート
    notes_slide = slide.notes_slide
    notes_slide.notes_text_frame.text = slide_data["notes"]

prs.save("output.pptx")
```

**テンプレートを使う場合:**

```python
# 会社のテンプレートを読み込んでデータだけ置換
prs = Presentation("company_template.pptx")
# 1 枚目のスライドをコピーして複製...
```

---

## どれを使うか

```
今すぐたたき台が欲しい
  └─ Claude.ai（Max/Teams以上）→ チャットで PPTX 生成

PowerPoint で作業しながら AI に頼みたい
  └─ Claude in PowerPoint アドイン

定型スライドを自動生成したい（CLI から）
  └─ claude-office-skills + Claude Code

完全自動化・大量生成
  └─ python-pptx + Claude API
```
