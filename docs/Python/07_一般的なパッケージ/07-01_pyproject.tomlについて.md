# pyproject.toml入門

## 概要
pyproject.tomlはPythonプロジェクトの構成と依存関係を一元管理するための設定ファイルです。

## 主要概念
pyproject.tomlはPEP 517/518によって導入された標準化された設定ファイルで、ビルドシステムや依存関係、開発ツールの設定を一箇所で管理できます。

## 実践：pyproject.tomlの作成と使用

### 1. 基本的なpyproject.tomlファイルの作成

まずは最も基本的なpyproject.tomlファイルを作成してみましょう。

```python
# プロジェクトのルートディレクトリに、pyproject.tomlファイルを作成します
# 以下のコードをコピーして、pyproject.tomlという名前で保存してください

[build-system]
requires = ["setuptools>=42", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "my-awesome-package"
version = "0.1.0"
description = "素晴らしいPythonパッケージ"
authors = [
    {name = "あなたの名前", email = "your.email@example.com"},
]
readme = "README.md"
requires-python = ">=3.8"
```

このファイルを作成したら、プロジェクトのルートディレクトリに配置します。このファイルだけでは何も起こりませんが、Pythonのパッケージ管理システムがこのファイルを読み取り、プロジェクトの構成を理解するための基本情報となります。

### 2. 依存関係の追加

次に、プロジェクトの依存関係を追加してみましょう。

```python
# pyproject.tomlに依存関係を追加します
# 既存のpyproject.tomlファイルに以下の内容を追加してください

[project]
# 上記の[project]セクションに以下を追加します
dependencies = [
    "requests>=2.28.0",
    "pandas>=1.5.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "black>=22.0.0",
    "isort>=5.10.0",
]
```

このコードを入力して保存してみましょう。これにより、あなたのプロジェクトが`requests`と`pandas`に依存していることを示します。また、開発環境のみで必要なパッケージも`dev`グループとして定義しています。

依存関係を定義したら、以下のコマンドでインストールできます：

```bash
# 基本的な依存関係のインストール
pip install -e .

# 開発用依存関係も含めてインストール
pip install -e ".[dev]"
```

実行結果：pipがpyproject.tomlを読み取り、指定された依存関係をインストールします。

### 3. 開発ツールの設定

多くの開発ツールはpyproject.tomlでの設定をサポートしています。以下は一般的なツールの設定例です。

```python
# pyproject.tomlに開発ツールの設定を追加します
# 既存のpyproject.tomlファイルに以下の内容を追加してください

[tool.black]
line-length = 88
target-version = ["py38", "py39", "py310"]
include = '\.pyi?$'

[tool.isort]
profile = "black"
line_length = 88

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = "test_*.py"
```

このコードを入力して保存してください。これにより：
- Black（コードフォーマッター）に最大行長を88文字に設定
- isort（importの整理ツール）をBlackと互換性のある設定に
- pytest（テストフレームワーク）にテストファイルのパスとパターンを指定

これらのツールを実行すると、pyproject.tomlから設定を自動的に読み込みます：

```bash
# Blackでコードをフォーマット
black .

# isortでimport文を整理
isort .

# pytestでテストを実行
pytest
```

実行結果：各ツールがpyproject.tomlの設定に従って動作します。

### 4. エントリーポイントの設定

CLIツールを作成する場合は、エントリーポイントを設定できます。

```python
# pyproject.tomlにエントリーポイントを追加します
# 既存のpyproject.tomlファイルに以下の内容を追加してください

[project.scripts]
my-tool = "my_package.cli:main"

[project.gui-scripts]
my-gui-tool = "my_package.gui:main"
```

このコードを入力して保存してください。これにより：
- コマンドライン（ターミナル）で`my-tool`コマンドを使用すると、`my_package.cli`モジュールの`main`関数が実行されます
- GUI用のエントリーポイントも同様に設定できます

パッケージをインストールした後、設定したコマンドが使用可能になります：

```bash
# パッケージをインストール
pip install -e .

# 設定したコマンドを実行
my-tool
```

実行結果：パッケージに定義した`main`関数が実行されます。

### 5. メタデータの充実

最後に、パッケージの詳細情報を追加してみましょう。

```python
# pyproject.tomlにメタデータを追加します
# 既存のpyproject.tomlファイルの[project]セクションを以下のように拡張してください

[project]
name = "my-awesome-package"
version = "0.1.0"
description = "素晴らしいPythonパッケージ"
authors = [
    {name = "あなたの名前", email = "your.email@example.com"},
]
readme = "README.md"
requires-python = ">=3.8"
license = {text = "MIT"}
keywords = ["example", "python", "package"]
classifiers = [
    "Development Status :: 3 - Alpha",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.8",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
    "License :: OSI Approved :: MIT License",
]

[project.urls]
"Homepage" = "https://github.com/yourusername/my-awesome-package"
"Bug Tracker" = "https://github.com/yourusername/my-awesome-package/issues"
"Documentation" = "https://my-awesome-package.readthedocs.io/"
```

このコードを入力して保存してください。これにより、パッケージの詳細情報がPyPIなどのリポジトリでより充実した形で表示されるようになります。

## まとめ

pyproject.tomlを使うことで、Pythonプロジェクトの依存関係、ビルド設定、開発ツールの設定を一元管理できます。初めは基本的な設定から始めて、プロジェクトの成長に合わせて徐々に設定を追加していくのがおすすめです。
