# Pythonの正規表現: re.splitとre.compileによる置換

## 概要
正規表現を使用した文字列の分割と置換は、テキスト処理において非常に強力なツールです。

## 理論的説明
Pythonの`re`モジュールは、`split()`メソッドでパターンに基づく分割を、`compile()`と`sub()`で効率的なパターンの置換を可能にします。

## 実践例

### 1. 基本的な文字列分割とre.splitの違い

以下のコードを入力して実行してみましょう：

```python
import re

# 通常の文字列分割
text = "my name is ... mike"
print("通常の分割:", text.split(sep=" "))

# 正規表現による分割
pattern = re.compile(r"\W+")  # \W は非単語文字（アルファベット、数字、アンダースコア以外）
print("正規表現による分割:", pattern.split(text))
```

**実行結果:**
```
通常の分割: ['my', 'name', 'is', '...', 'mike']
正規表現による分割: ['my', 'name', 'is', 'mike']
```

**解説:**
- 通常の`split()`は指定した区切り文字（この場合は空白）でのみ分割します。
- `re.split()`は正規表現パターンに一致する箇所で分割するため、`\W+`（1つ以上の非単語文字）を指定することで、空白だけでなく記号なども含めて分割できます。

### 2. re.compileとsub()による文字列置換

以下のコードを入力して実行してみましょう：

```python
import re

# 基本的な置換
pattern = re.compile("(blue|white|red)")  # blue, white, redのいずれかにマッチ
text = "blue socks and red shoes"

# すべて置換
print("すべて置換:", pattern.sub("colour", text))

# 最初の1つだけ置換
print("1つだけ置換:", pattern.sub("colour", text, count=1))

# 置換回数のカウント
replaced_text, count = pattern.subn("colour", text)
print(f"置換結果: {replaced_text}, 置換回数: {count}")
```

**実行結果:**
```
すべて置換: colour socks and colour shoes
1つだけ置換: colour socks and red shoes
置換結果: colour socks and colour shoes, 置換回数: 2
```

**解説:**
- `re.compile()`でパターンをコンパイルしておくと、同じパターンを繰り返し使う場合に効率的です。
- `sub()`メソッドは第1引数に置換文字列、第2引数に対象文字列を指定します。
- `count`パラメータで置換する最大回数を制限できます。
- `subn()`は置換結果と置換回数をタプルで返します。

### 3. 関数を使った高度な置換

以下のコードを入力して実行してみましょう：

```python
import re

# 置換用の関数を定義
def hexrepl(match):
    """マッチした数字を16進数に変換する関数"""
    value = int(match.group())  # マッチした文字列を数値に変換
    return hex(value)  # 16進数表記に変換

# 数字にマッチするパターン
pattern = re.compile(r"\d")  # \dは任意の数字にマッチ

# 関数を使った置換
text = "12345 55 11 test test2"
print("関数による置換:", pattern.sub(hexrepl, text))
```

**実行結果:**
```
関数による置換: 0x10x20x30x40x5 0x50x5 0x10x1 test test0x2
```

**解説:**
- `sub()`の第1引数には関数を指定することもできます。
- この関数は、マッチオブジェクトを引数として受け取り、置換する文字列を返します。
- この例では、文字列中の各数字を見つけて16進数表記に変換しています。
- `match.group()`でマッチした部分の文字列を取得しています。

## まとめ

Pythonの正規表現を使った文字列処理の基本的な方法を学びました：
- `re.split()`で柔軟な文字列分割が可能
- `re.compile()`でパターンをコンパイルしておくと効率的
- `sub()`と`subn()`で文字列置換ができる
- 置換処理に関数を使うことで、より複雑な変換も実現できる
