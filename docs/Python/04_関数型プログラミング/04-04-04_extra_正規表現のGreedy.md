# Pythonで学ぶ正規表現のGreedy

## 1. 概要と重要性

正規表現における「Greedy（貪欲）」マッチングは、パターンマッチングの挙動を理解する上で非常に重要な概念です。

## 2. 理論的説明

正規表現のデフォルトは「Greedy（貪欲）」モードであり、マッチする最も長い文字列を返します。一方、「Non-Greedy（非貪欲）」モードは最短のマッチを返します。

## 3. 実践コード例

### 基本的なGreedyマッチング

以下のコードを入力して実行してみましょう：

```python
import re

# HTML文字列を定義
html_text = "<html><head><title>Title</title></head></html>"

# Greedyマッチング (デフォルト): `*` は可能な限り多くの文字にマッチ
greedy_match = re.match("<.*>", html_text)
print("Greedyマッチング結果:", greedy_match.group())

# Non-Greedyマッチング: `*?` は可能な限り少ない文字にマッチ
non_greedy_match = re.match("<.*?>", html_text)
print("Non-Greedyマッチング結果:", non_greedy_match.group())
```

#### 実行結果

```
Greedyマッチング結果: <html><head><title>Title</title></head></html>
Non-Greedyマッチング結果: <html>
```

#### 解説

- `<.*>` というパターンでは：
  - `<` は文字「<」にマッチ
  - `.*` は任意の文字（`.`）が0回以上（`*`）繰り返す部分にマッチ
  - `>` は文字「>」にマッチ
  - Greedyモードでは、最後の `>` までの全体にマッチするため、HTML全体にマッチします

- `<.*?>` というパターンでは：
  - `?` が `*` の後に付くことでNon-Greedyモードになり、最短のマッチを返します
  - よって最初の `<html>` タグだけにマッチします

### 実用的な例：HTMLタグの抽出

以下のコードを入力して実行してみましょう：

```python
import re

# サンプルHTML
html_content = "<div>最初の div</div><p>段落</p><div>2番目の div</div>"

# Greedyマッチングを使用した場合（全てのdivタグの間の内容を抽出）
greedy_pattern = "<div>(.*)</div>"
greedy_result = re.search(greedy_pattern, html_content)
print("Greedyマッチング結果:", greedy_result.group(1))

# Non-Greedyマッチングを使用した場合（最初のdivタグの内容だけを抽出）
non_greedy_pattern = "<div>(.*?)</div>"
non_greedy_result = re.search(non_greedy_pattern, html_content)
print("Non-Greedyマッチング結果:", non_greedy_result.group(1))

# 全てのdivタグの内容を抽出
all_div_contents = re.findall("<div>(.*?)</div>", html_content)
print("全てのdivタグの内容:", all_div_contents)
```

#### 実行結果

```
Greedyマッチング結果: 最初の div</div><p>段落</p><div>2番目の div
Non-Greedyマッチング結果: 最初の div
全てのdivタグの内容: ['最初の div', '2番目の div']
```

#### 解説

1. Greedyマッチング（`<div>(.*)</div>`）では：
   - 最初の `<div>` から最後の `</div>` までの全ての内容にマッチ
   - 中間の閉じタグと開始タグも含めて全てマッチしてしまう

2. Non-Greedyマッチング（`<div>(.*?)</div>`）では：
   - 各 `<div>` タグに対して最小限のマッチングを行う
   - 最初の例では最初の div タグの内容のみにマッチ
   - `findall()` を使うと全ての div タグの内容を抽出できる

### 量指定子とGreedy

以下のコードを入力して実行してみましょう：

```python
import re

# サンプル文字列
text = "aaabbbccc"

# 貪欲マッチング: a が1回以上繰り返す場合
greedy_plus = re.match("a+", text)
print("a+ (貪欲):", greedy_plus.group())

# 非貪欲マッチング: a が1回以上繰り返す場合（最短）
non_greedy_plus = re.match("a+?", text)
print("a+? (非貪欲):", non_greedy_plus.group())

# 貪欲マッチング: a が0〜3回繰り返す場合
greedy_range = re.match("a{1,3}", text)
print("a{1,3} (貪欲):", greedy_range.group())

# 非貪欲マッチング: a が0〜3回繰り返す場合（最短）
non_greedy_range = re.match("a{1,3}?", text)
print("a{1,3}? (非貪欲):", non_greedy_range.group())
```

#### 実行結果

```
a+ (貪欲): aaa
a+? (非貪欲): a
a{1,3} (貪欲): aaa
a{1,3}? (非貪欲): a
```

#### 解説

- `+` は1回以上の繰り返しを表します
  - `a+` は「a」が1回以上連続する場合にマッチし、デフォルトでは最長の「aaa」にマッチ
  - `a+?` は非貪欲モードなので、最短の「a」1文字だけにマッチ

- `{1,3}` は1回から3回の繰り返しを表します
  - `a{1,3}` は「a」が1〜3回連続する場合にマッチし、デフォルトでは最長の「aaa」にマッチ
  - `a{1,3}?` は非貪欲モードなので、最短の「a」1文字だけにマッチ

### 実践的なユースケース：データ抽出

以下のコードを入力して実行してみましょう：

```python
import re

# ログデータのサンプル
log_data = """
[2023-01-01] ユーザーAがログイン
[2023-01-01] エラー: ファイルが見つかりません
[2023-01-02] ユーザーBがログイン
[2023-01-02] 処理が完了しました
"""

# 貪欲マッチングを使用したエラーメッセージの抽出（意図した結果にならない）
greedy_pattern = "\[.*\] エラー: (.*)"
greedy_errors = re.findall(greedy_pattern, log_data)
print("貪欲マッチングによるエラー抽出:", greedy_errors)

# 非貪欲マッチングを使用したエラーメッセージの抽出（日付ごとに正確に抽出）
non_greedy_pattern = "\[.*?\] エラー: (.*)"
non_greedy_errors = re.findall(non_greedy_pattern, log_data)
print("非貪欲マッチングによるエラー抽出:", non_greedy_errors)

# すべての日付を抽出
dates = re.findall("\[(.*?)\]", log_data)
print("抽出された日付:", dates)
```

#### 実行結果

```
貪欲マッチングによるエラー抽出: ['ファイルが見つかりません']
非貪欲マッチングによるエラー抽出: ['ファイルが見つかりません']
抽出された日付: ['2023-01-01', '2023-01-01', '2023-01-02', '2023-01-02']
```

#### 解説

- エラーメッセージの抽出では、今回のサンプルデータでは貪欲・非貪欲どちらも同じ結果ですが、複数行にわたるデータでは違いが出る場合があります
- 日付の抽出では `\[(.*?)\]` パターンを使い、非貪欲マッチングで各角括弧の中身を抽出しています
- 非貪欲マッチングを使うことで、各行の日付を個別に取得できています

### まとめ

- Greedyマッチング（デフォルト）: 可能な限り多くの文字にマッチ（`*`, `+`, `{n,m}`）
- Non-Greedyマッチング: 可能な限り少ない文字にマッチ（`*?`, `+?`, `{n,m}?`）
- 実際の使用では、意図したデータを正確に抽出するために、状況に応じて適切なモードを選択することが重要です
