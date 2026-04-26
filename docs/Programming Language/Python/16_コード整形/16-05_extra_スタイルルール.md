# Python スタイルガイド

## 概要
Pythonコーディングスタイルは読みやすく保守性の高いコードを書くための重要な指針です。

## 基本概念
PEP 8はPythonの公式スタイルガイドであり、コードの可読性と一貫性を高めるための規約を定めています。

## スタイルルールと実践例

### 1. 基本的なフォーマットルール

#### セミコロンの使用を避ける

```python
# 良くない例 - セミコロンで文を連結すると読みづらい
x = 1; y = 2;

# 良い例 - 1行に1文で書く
x = 1
y = 2
```

このコードを入力して実行してみましょう。どちらも同じ結果になりますが、下の書き方のほうが読みやすいです。

#### 行の長さは80文字以内に

```python
# 良くない例 - 80文字を超える長い行
x = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'

# 良い例 - 適切な長さに分割するか短くする
x = ('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
     'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
```

このコードを入力して実行してみましょう。長い文字列は括弧で囲んで複数行に分けることができます。

#### 長い関数呼び出しの整形

```python
# 良い例 - 引数が多い場合は複数行に分け、インデントを揃える
def test_func(x, y, z,
              long_parameter_name='test'):
    """
    URL は80文字超えてもOK
    see details at: https://example.com/very-long-url-is-acceptable-in-docstrings
    """
    print(x, y, z, long_parameter_name)

# 実行してみましょう
test_func(1, 2, 3)
```

実行すると `1 2 3 test` と表示されます。引数が多い場合、このように整形すると読みやすくなります。

### 2. 条件文と括弧の使用

```python
# 良くない例 - 不要な括弧
x = True
y = False
if (x and y):
    print('両方True')

# 良い例 - 不要な括弧を省略
if x and y:
    print('両方True')
```

このコードを入力して実行してみましょう。Pythonでは条件式に不要な括弧をつける必要はありません。

### 3. インデント

```python
# 良くない例 - スペース2つのインデント
x = True
if x:
  print('xはTrue')

# 良い例 - スペース4つのインデント
if x:
    print('xはTrue')
```

このコードを入力して実行してみましょう。Pythonでは一貫してスペース4つでインデントするのが標準的です。

### 4. データ構造のフォーマット

```python
# 良くない例 - 辞書のインデントがスペース2つ
x = {
  'test': "aaa"
}

# 良い例 - スペース4つのインデント
x = {
    'test': "aaa"
}

# 1行で書く場合は、カンマの後にスペースを入れる
# 良くない例
x = {'test':"aaa",'test2':'bbb'}

# 良い例
x = {'test': "aaa", 'test2': 'bbb'}
```

このコードを入力して実行してみましょう。データ構造のフォーマットも一貫性を持たせることが重要です。

### 5. 演算子の周りのスペース

```python
# 良くない例 - 代入演算子の周りにスペースがない
x=10

# 良い例 - 代入演算子の前後にスペースを入れる
x = 10
```

このコードを入力して実行してみましょう。演算子の周りにスペースを入れると読みやすくなります。

### 6. クラスと関数の定義間隔

```python
# 良くない例 - 間隔が不足している
def test_func():
    pass

class Test():
    def __init__(self):
        print('test')

# 良い例 - クラスや関数の間は2行空ける

def test_func():
    pass


class Test():
    def __init__(self):
        print('test')
```

このコードを入力して実行してみましょう。適切な空行を入れることでコードの構造が明確になります。

### 7. 文字列の連結

```python
# 変数準備
word = 'hello'
word2 = '!'

# 避けるべき方法
new_word = f'{word}{word2}'

# 良い方法 - 直感的でわかりやすい
new_word = word + word2
print(new_word)  # 出力: hello!

# 間に文字を挿入する場合はf文字列も有効
new_word = f'{word} world{word2}'
print(new_word)  # 出力: hello world!
```

このコードを入力して実行してみましょう。単純な文字列連結は `+` 演算子を使うのが読みやすいです。

### 8. 文字列の結合と効率的なメモリ使用

```python
# 良くない例 - メモリ効率が悪い
words = ['Python', 'is', 'awesome']
long_word = ""
for word in words:
    long_word += word + " "
print(long_word)  # 出力: Python is awesome 

# 良い例 - リストに追加してから結合
words = ['Python', 'is', 'awesome']
word_parts = []
for word in words:
    word_parts.append(word)
new_long_word = ' '.join(word_parts)
print(new_long_word)  # 出力: Python is awesome
```

このコードを入力して実行してみましょう。文字列を繰り返し連結するより、リストに追加してから`join`メソッドで結合する方が効率的です。

### 9. クォーテーションの一貫性

```python
# シングルクォーテーションとダブルクォーテーションはどちらでも良いが、一貫していること
print('single quotes')
print("double quotes")

# 文字列内にクォーテーションが含まれる場合は異なるタイプを使うと便利
print("It's a nice day")
print('He said "Hello"')
```

このコードを入力して実行してみましょう。どちらのクォーテーションスタイルを選んでも構いませんが、プロジェクト内で一貫性を保ちましょう。

### 10. ファイル操作の安全な方法

```python
# 良い例 - withステートメントを使用する
with open('test.txt', 'w') as text_file:
    text_file.write('Hello, Python style guide!')

# ファイルを読み込む
with open('test.txt', 'r') as text_file:
    content = text_file.read()
    print(content)  # 出力: Hello, Python style guide!
```

このコードを入力して実行してみましょう。`with`ステートメントを使うと、ファイルが自動的に閉じられ、例外が発生しても適切に処理されます。

### 11. TODOコメントの書き方

```python
# TODO(username): 実装が必要な機能の説明
# TODO(haruka-aibara): ユーザー認証機能を追加する

def incomplete_function():
    # TODO(haruka-aibara): エラー処理を追加する
    print("この関数はまだ完成していません")
```

このコードを入力して実行してみましょう。TODOコメントには担当者と詳細を記載すると、後で見直す際に役立ちます。

### 12. 条件文の書き方

```python
# 良い例 - 複数行で書く
x = True
if x:
    print('xはTrue')

# 避けるべき例 - 1行に書く（短いコードでも可読性が低下）
if x: print('xはTrue')
```

このコードを入力して実行してみましょう。条件文は複数行で書くと読みやすくなります。

### 13. 命名規則

```python
# クラスはキャメルケース（単語の先頭を大文字に）
class TestClass:
    def __init__(self):
        print('クラスのインスタンスを作成しました')

# 変数・関数はスネークケース（小文字とアンダースコア）
user_name = 'test_user'
def calculate_total_price(price, tax):
    return price * (1 + tax)

# グローバル定数は全て大文字とアンダースコア
DEFAULT_TAX_RATE = 0.1

# 実行してみましょう
test = TestClass()
total = calculate_total_price(1000, DEFAULT_TAX_RATE)
print(f"{user_name}の支払金額: {total}円")  # 出力: test_userの支払金額: 1100.0円
```

このコードを入力して実行してみましょう。適切な命名規則に従うことで、コードの可読性が向上します。

### 14. プロパティの使用

```python
class User:
    def __init__(self, name):
        self._name = name
    
    # 良い例 - propertyデコレータを使用
    @property
    def name(self):
        return self._name
    
    # 避けるべき例 - get_プレフィックスを使用
    # def get_name(self):
    #     return self._name

# 実行してみましょう
user = User("Python")
print(user.name)  # 出力: Python（プロパティを使用）
# print(user.get_name())  # 古い方法
```

このコードを入力して実行してみましょう。プロパティを使うと、より自然な形で属性にアクセスできます。

### 15. スクリプトとしての実行

```python
def main():
    print("メイン関数が実行されました")

# スクリプトとして実行された場合のみmain関数を呼び出す
if __name__ == '__main__':
    main()
```

このコードを入力して実行してみましょう。`if __name__ == '__main__':`を使うことで、モジュールとしてインポートされた時には実行されない処理を定義できます。
