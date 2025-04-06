# モジュールのパッケージ化（setup.py）

## 概要

Pythonのモジュールをパッケージ化することで、コードを再利用可能な形で配布・インストールできるようになります。

## 主要概念

`setup.py`は、Pythonパッケージの配布とインストールを管理するための設定ファイルで、setuptools/distutilsライブラリを使用します。

## パッケージ化の手順

### Step 1: プロジェクト構造を作成する

まずは以下のようなプロジェクト構造を作成します。

```
my_package/
├── my_package/
│   ├── __init__.py
│   ├── module1.py
│   └── module2.py
├── setup.py
└── README.md
```

このコードを入力して実行してみましょう：

```bash
mkdir -p my_package/my_package
touch my_package/my_package/__init__.py
touch my_package/my_package/module1.py
touch my_package/my_package/module2.py
touch my_package/setup.py
touch my_package/README.md
```

実行結果：
上記のコマンドを実行すると、必要なディレクトリ構造とファイルが作成されます。

### Step 2: モジュールのコードを作成する

`__init__.py`ファイルに以下のコードを追加します：

```python
# my_package/__init__.py
from .module1 import hello_world
from .module2 import calculate_sum

__version__ = '0.1.0'
```

`module1.py`ファイルに以下のコードを追加します：

```python
# my_package/module1.py
def hello_world():
    """シンプルな挨拶関数"""
    return "Hello, World!"
```

`module2.py`ファイルに以下のコードを追加します：

```python
# my_package/module2.py
def calculate_sum(a, b):
    """2つの数値の合計を計算する関数
    
    Args:
        a: 1つ目の数値
        b: 2つ目の数値
        
    Returns:
        aとbの合計
    """
    return a + b
```

このコードを入力して実行してみましょう。各ファイルにコードを追加したら、次のステップに進みます。

### Step 3: setup.pyファイルを作成する

`setup.py`ファイルは、パッケージに関する情報を定義します。以下のコードを`setup.py`に追加します：

```python
# setup.py
from setuptools import setup, find_packages

setup(
    name="my_package",             # パッケージ名
    version="0.1.0",               # バージョン
    author="Your Name",            # 作者名
    author_email="your.email@example.com",  # 作者のメールアドレス
    description="A simple example package",  # 簡単な説明
    long_description=open("README.md").read(),  # 詳細な説明（README.mdから読み込み）
    long_description_content_type="text/markdown",  # 詳細説明の形式
    url="https://github.com/yourusername/my_package",  # プロジェクトのURL
    packages=find_packages(),      # パッケージを自動検出
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.6",       # 必要なPythonバージョン
    install_requires=[
        # 依存パッケージがあれば記載
        # "numpy>=1.18.0",
        # "pandas>=1.0.0",
    ],
)
```

このコードを入力して実行してみましょう。`setup.py`にコードを追加したら、次のステップに進みます。

### Step 4: READMEファイルを作成する

`README.md`ファイルに以下の内容を追加します：

```markdown
# My Package

シンプルなPythonパッケージの例です。

## インストール方法

```bash
pip install my_package
```

## 使用例

```python
from my_package import hello_world, calculate_sum

print(hello_world())
print(calculate_sum(5, 3))
```
```

このコードを入力して実行してみましょう。`README.md`にコードを追加したら、次のステップに進みます。

### Step 5: パッケージをインストール可能な形式にビルドする

パッケージをビルドするには、以下のコマンドを実行します：

```bash
cd my_package
pip install -e .
```

実行結果：
このコマンドは、現在のディレクトリ（`.`）にあるパッケージを開発モード（`-e`）でインストールします。出力には、パッケージが正常にインストールされたことを示すメッセージが表示されます。

### Step 6: パッケージをテストする

インストールしたパッケージをテストするために、以下のPythonスクリプトを作成して実行しましょう：

```python
# test_package.py
from my_package import hello_world, calculate_sum

print(hello_world())
print(calculate_sum(10, 5))
```

このコードを入力して実行してみましょう：

```bash
python test_package.py
```

実行結果：
```
Hello, World!
15
```

上記の出力が表示されれば、パッケージが正常にインストールされ、機能していることが確認できます。

### Step 7: パッケージを配布用にビルドする

パッケージを配布用にビルドするには、以下のコマンドを実行します：

```bash
cd my_package
python setup.py sdist bdist_wheel
```

実行結果：
このコマンドは、`dist`ディレクトリ内にソースディストリビューション（`.tar.gz`ファイル）とビルドディストリビューション（`.whl`ファイル）を作成します。これらのファイルは、PyPIにアップロードしたり、他のユーザーに直接配布したりするために使用できます。

### Step 8: （オプション）PyPIにパッケージをアップロードする

PyPIにパッケージをアップロードするには、まず`twine`をインストールする必要があります：

```bash
pip install twine
```

そして、以下のコマンドでアップロードします：

```bash
twine upload dist/*
```

実行結果：
パッケージがPyPIにアップロードされます。（注意事項参照）

注意事項：
アップロードには、PyPIの API トークンが必要です。
また、上記 my_package はサンプル名ですので、上記コードそのままではアップロードはされません。
実際にPyPIにアップロードする場合は、既存のパッケージと重複しない**ユニークな名前**を使用する必要があります。
PyPIで使用可能な名前かどうかは、https://pypi.org で検索するか、実際にアップロードを試みることで確認できます。

## まとめ

以上の手順により、Pythonモジュールをパッケージ化し、配布可能な形式にすることができました。`setup.py`を使用することで、依存関係の管理やメタデータの定義など、パッケージに関する様々な設定を行うことができます。
