# Sphinxを使ったドキュメント作成入門

## 概要
Sphinxは、特にPythonプロジェクトのドキュメント作成に適した強力な文書生成ツールです。

## 基本概念
Sphinxは、reStructuredTextやMarkdownで書かれたソースファイルから、HTML、PDF、ePubなど様々な形式のドキュメントを生成します。

## Sphinxの使い方（ステップバイステップ）

### 1. Sphinxのインストール

まずはPythonのパッケージマネージャーpipを使ってSphinxをインストールします。ターミナルで以下のコマンドを実行してください。

```python
# Sphinxとマークダウン拡張機能のインストール
pip install sphinx sphinx-rtd-theme recommonmark
```

### 2. プロジェクトの初期設定

Sphinxプロジェクトを初期化します。以下のコマンドを実行してみましょう。

```bash
# ドキュメント用のディレクトリを作成して移動
mkdir my_sphinx_docs
cd my_sphinx_docs

# Sphinxプロジェクトを初期化
sphinx-quickstart
```

実行すると、対話形式で設定を行います。基本的な質問に答えて設定を行いましょう：

- `Separate source and build directories (y/n) [n]:` → `y` と入力
- `Project name:` → プロジェクト名を入力（例：`My Python Project`）
- `Author name(s):` → あなたの名前を入力
- `Project release:` → バージョン番号を入力（例：`0.1`）
- `Project language [en]:` → `ja` と入力（日本語の場合）

その他の質問はデフォルト値（Enterを押す）で問題ありません。

### 3. Markdown対応の設定

SphinxはデフォルトでreStructuredTextを使用しますが、Markdownも使えるように設定を変更します。`source/conf.py`ファイルを開き、以下のように編集してください。

```python
# このコードを入力して実行してみましょう
# conf.pyファイルの編集例

# 拡張機能の設定に以下を追加
extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.viewcode',
    'sphinx.ext.napoleon',
    'recommonmark'  # Markdown対応
]

# テーマの設定
html_theme = 'sphinx_rtd_theme'

# Markdownファイルも処理対象に追加
source_suffix = {
    '.rst': 'restructuredtext',
    '.md': 'markdown',
}
```

### 4. マークダウンファイルの作成

`source`ディレクトリに`example.md`という名前でMarkdownファイルを作成します。

```markdown
# Pythonプログラミング入門

## 変数と基本データ型

Pythonでは変数宣言に特別な構文は必要ありません。

```python
# 整数型
age = 30
print(f"年齢: {age}")

# 文字列型
name = "山田太郎"
print(f"名前: {name}")

# リスト型
fruits = ["りんご", "バナナ", "オレンジ"]
print(f"果物リスト: {fruits}")
```

## 条件分岐

```python
temperature = 28

if temperature > 30:
    print("暑いですね！")
elif temperature > 20:
    print("過ごしやすい気温です")
else:
    print("少し肌寒いです")
```
```

### 5. インデックスページの編集

`source/index.rst`ファイルを開いて、以下のように編集します。

```rst
My Python Projectドキュメント
===========================

.. toctree::
   :maxdepth: 2
   :caption: 目次:

   example

目次とインデックス
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
```

### 6. ドキュメントのビルド

以下のコマンドを実行して、HTMLドキュメントを生成します。

```bash
# ドキュメントをHTMLにビルド
make html
```

このコマンドを実行すると、`build/html`ディレクトリにHTMLファイルが生成されます。

### 7. ドキュメントの確認

生成されたHTMLファイルをブラウザで確認します。`build/html/index.html`をブラウザで開いてみましょう。コマンドラインから開く場合は以下のようにします（OSによって異なります）：

```bash
# MacOSの場合
open build/html/index.html

# Linuxの場合
xdg-open build/html/index.html

# Windowsの場合
start build/html/index.html
```

ブラウザでHTMLファイルが開かれ、作成したドキュメントが表示されます。左側にナビゲーションメニュー、右側に本文が表示される構造になっています。

### 8. Python関数のドキュメント化

Pythonソースコードからドキュメントを自動生成する例を見てみましょう。`source`ディレクトリに`example_module.py`というファイルを作成します。

```python
# example_module.py
def calculate_bmi(weight, height):
    """BMI（ボディマス指数）を計算する関数
    
    Args:
        weight (float): 体重（kg）
        height (float): 身長（m）
        
    Returns:
        float: 計算されたBMI値
        
    Examples:
        >>> calculate_bmi(70, 1.75)
        22.86
    """
    return weight / (height ** 2)

class Person:
    """人物を表すクラス
    
    Attributes:
        name (str): 人物の名前
        age (int): 人物の年齢
    """
    
    def __init__(self, name, age):
        """コンストラクタ
        
        Args:
            name (str): 人物の名前
            age (int): 人物の年齢
        """
        self.name = name
        self.age = age
        
    def greet(self):
        """挨拶メッセージを返す
        
        Returns:
            str: 挨拶メッセージ
        """
        return f"こんにちは、{self.name}です。{self.age}歳です。"
```

次に、`source`ディレクトリに`code_docs.rst`ファイルを作成します。

```rst
コード自動ドキュメント
====================

Example Module
-------------

.. automodule:: example_module
   :members:
   :undoc-members:
   :show-inheritance:
```

`source/index.rst`ファイルに新しく作成した`code_docs.rst`を追加します。

```rst
My Python Projectドキュメント
===========================

.. toctree::
   :maxdepth: 2
   :caption: 目次:

   example
   code_docs

目次とインデックス
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
```

`conf.py`ファイルを編集して、Pythonのモジュールを見つけられるようにします。

```python
# conf.pyに以下を追加
import os
import sys
sys.path.insert(0, os.path.abspath('.'))
```

再度ドキュメントをビルドして確認します。

```bash
make html
```

ブラウザでHTMLファイルを開くと、コードからドキュメントが自動生成されていることが確認できます。

## まとめ

Sphinxを使うと、以下のようなことができます：

1. マークダウンやreStructuredTextで簡単に文書作成
2. コードからドキュメントを自動生成
3. 様々な形式（HTML、PDF、ePub）への出力
4. 目次や索引を自動生成

これらの機能を活用して、プロジェクトのドキュメントを効率的に作成・管理できます。
