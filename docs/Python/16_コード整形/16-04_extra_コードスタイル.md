# Pythonコードスタイルガイド

## 概要
Pythonにおけるコードスタイルは可読性と保守性を高め、チーム開発を円滑にするための重要な要素です。

## 主要概念
Pythonコードスタイルは「PEP 8」というスタイルガイドに基づいており、コードの一貫性を保つために広く採用されています。

## コードスタイル検証ツールのインストール

Pythonのコードスタイルを自動的にチェックするための便利なツールがあります。以下のステップでインストールしてみましょう。

### ステップ1: 標準的なpipを使用してインストール

以下のコマンドを入力して実行してみましょう：

```python
# pycodestyleのインストール（以前はpep8という名前でした）
pip install pycodestyle

# flake8のインストール（PEP 8のチェック機能とさらに高度な検証機能を持つツール）
pip install flake8

# pylintのインストール（より包括的なコード分析ツール）
pip install pylint
```

**実行結果**: 各ツールがインストールされ、成功メッセージが表示されます。

### ステップ2: uvツールを使用してインストール（代替方法）

uvは高速なPythonパッケージインストーラーです。利用している場合は以下のコマンドでインストールできます：

```python
# pycodestyleのインストール
uv tool install pycodestyle

# flake8のインストール
uv tool install flake8

# pylintのインストール
uv tool install pylint
```

**実行結果**: uvツールを使って各パッケージがインストールされます。

## ツールの使用例

### flake8の使用例

以下のコードを`bad_style.py`というファイル名で保存してみましょう：

```python
# bad_style.py
def add_numbers( a,b ):
    x=a+b # 変数の前後にスペースがない
    return   x  # スペースが多すぎる
```

次に、以下のコマンドを入力して実行してみましょう：

```bash
flake8 bad_style.py
```

**実行結果**:
```
bad_style.py:1:17: E201 whitespace after '('
bad_style.py:1:20: E231 missing whitespace after ','
bad_style.py:2:6: E225 missing whitespace around operator
bad_style.py:3:11: E272 multiple spaces before keyword
```

これは、コード内のスタイル違反を示しています。

### 修正例

以下のように修正しましょう。`good_style.py`というファイル名で保存します：

```python
# good_style.py
def add_numbers(a, b):
    """2つの数値を加算する関数"""
    result = a + b  # 適切にスペースを使用
    return result
```

同じようにflake8で確認します：

```bash
flake8 good_style.py
```

**実行結果**: エラーメッセージがなければ、コードがPEP 8に準拠していることを意味します。

### pylintの使用例

pylintはより詳細な分析ができます。以下のコマンドを実行してみましょう：

```bash
pylint good_style.py
```

**実行結果**: コードの品質スコアや改善の提案が表示されます。

## PEP 8の主要なルール

以下は守るべき重要なルールの例です：

### インデント

```python
# このコードを入力して実行してみましょう
def correct_indentation():
    # 4つのスペースを使用
    if True:
        # さらに4つのスペース
        print("正しいインデント")
```

**実行結果**: `正しいインデント` と表示されます。

### 命名規則

```python
# このコードを入力して実行してみましょう
# 変数名とは小文字のスネークケース
first_name = "太郎"

# クラス名はキャメルケース（最初も大文字）
class PersonInfo:
    def __init__(self, name):
        self.name = name
        
# 定数は大文字とアンダースコア
MAX_VALUE = 100

print(f"名前: {first_name}, 最大値: {MAX_VALUE}")
```

**実行結果**: `名前: 太郎, 最大値: 100` と表示されます。

### 空白の使い方

```python
# このコードを入力して実行してみましょう
# 演算子の前後にスペース
total = 5 + 10

# カンマの後にスペース
fruits = ["りんご", "みかん", "バナナ"]

# 関数の引数のカンマ後にスペース
def greet(name, age):
    print(f"こんにちは、{name}さん。{age}歳ですね。")

greet("山田", 25)
```

**実行結果**: `こんにちは、山田さん。25歳ですね。` と表示されます。

## まとめ

Pythonのコードスタイルツールを活用することで、一貫性のある読みやすいコードを書くことができます。PEP 8のガイドラインに従うことは、プロフェッショナルなPythonプログラマーへの第一歩です。
