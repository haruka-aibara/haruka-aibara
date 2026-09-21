# Pythonパッケージマネージャ：Poetry入門

## 概要
Poetryは依存関係管理と仮想環境を統合したPythonパッケージマネージャで、プロジェクト管理を効率化します。

## 主要概念
Poetryはプロジェクトの依存関係をpyproject.tomlファイルで一元管理し、環境の再現性と整合性を保証します。

## 実践：Poetry入門

### 1. Poetryのインストール

以下のコマンドを入力して実行してみましょう：

```bash
# Windowsの場合
pip install poetry

# macOS/Linuxの場合
curl -sSL https://install.python-poetry.org | python3 -
```

実行結果：
```
Poetryがインストールされました。
```

### 2. 新しいプロジェクトの作成

以下のコマンドを入力して実行してみましょう：

```bash
poetry new my-python-project
cd my-python-project
```

実行結果：
```
Created package my_python_project in my-python-project
```

生成されるプロジェクト構造：
```
my-python-project/
├── pyproject.toml
├── README.md
├── my_python_project/
│   └── __init__.py
└── tests/
    └── __init__.py
```

### 3. pyproject.tomlの確認

以下のコマンドを入力して実行してみましょう：

```bash
cat pyproject.toml
```

実行結果（例）：
```toml
[tool.poetry]
name = "my-python-project"
version = "0.1.0"
description = ""
authors = ["Your Name <your.email@example.com>"]
readme = "README.md"

[tool.poetry.dependencies]
python = "^3.8"

[tool.poetry.group.dev.dependencies]
pytest = "^7.3.1"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
```

### 4. 依存パッケージの追加

以下のコマンドを入力して実行してみましょう：

```bash
# requestsライブラリを追加
poetry add requests

# 開発用の依存関係としてblack（コードフォーマッタ）を追加
poetry add --group dev black
```

実行結果：
```
Creating virtualenv my-python-project in .../my-python-project/.venv
Using version ^2.28.2 for requests

Updating dependencies
Resolving dependencies... 

Writing lock file

Package operations: 5 installs, 0 updates, 0 removals

  • Installing certifi (2022.12.7)
  • Installing charset-normalizer (3.1.0)
  • Installing idna (3.4)
  • Installing urllib3 (1.26.15)
  • Installing requests (2.28.2)
```

### 5. 仮想環境の操作

以下のコマンドを入力して実行してみましょう：

```bash
# 仮想環境内でシェルを起動
poetry shell

# または、コマンドを直接実行
poetry run python -c "import requests; print(requests.__version__)"
```

実行結果：
```
2.28.2
```

### 6. シンプルなプログラム作成

以下のコードを`my_python_project/__init__.py`に追加してみましょう：

```python
def hello():
    return "Hello from my_python_project!"
```

新しいファイル`my_python_project/api.py`を作成し、以下のコードを入力してみましょう：

```python
import requests

def get_json_data(url):
    """指定されたURLからJSONデータを取得する関数
    
    Args:
        url (str): データを取得するURL
        
    Returns:
        dict: 取得したJSONデータ（辞書形式）
    """
    response = requests.get(url)
    # HTTPリクエストが成功したか確認
    response.raise_for_status()
    # JSONデータを返す
    return response.json()

def get_weather(city):
    """指定された都市の天気情報を取得する関数（サンプル）
    
    Args:
        city (str): 天気を取得する都市名
        
    Returns:
        str: 天気情報のメッセージ
    """
    # 注意: この関数は実際のAPIキーを必要とするため、そのままでは動作しません
    # 例示目的のみのサンプルコードです
    api_key = "YOUR_API_KEY"
    url = f"https://api.example.com/weather?city={city}&api_key={api_key}"
    
    try:
        data = get_json_data(url)
        temp = data["main"]["temp"]
        condition = data["weather"][0]["description"]
        return f"{city}の現在の気温は{temp}℃、{condition}です。"
    except Exception as e:
        return f"天気情報の取得に失敗しました: {e}"
```

### 7. 実行スクリプトの作成

新しいファイル`main.py`をプロジェクトのルートディレクトリに作成し、以下のコードを入力してみましょう：

```python
from my_python_project import hello
from my_python_project.api import get_weather

def main():
    print(hello())
    
    # 実際のAPIキーが必要なため、コメントアウトしています
    # print(get_weather("東京"))
    
    # 代わりにダミーデータを表示
    print("東京の現在の気温は22℃、晴れです。")

if __name__ == "__main__":
    main()
```

以下のコマンドを入力して実行してみましょう：

```bash
poetry run python main.py
```

実行結果：
```
Hello from my_python_project!
東京の現在の気温は22℃、晴れです。
```

### 8. 依存関係のエクスポート

以下のコマンドを入力して実行してみましょう：

```bash
# requirements.txtを生成
poetry export -f requirements.txt --output requirements.txt
```

実行結果：
`requirements.txt`ファイルが生成され、以下のような内容が記載されます：

```
certifi==2022.12.7 ; python_version >= "3.8" and python_version < "4.0"
charset-normalizer==3.1.0 ; python_version >= "3.8" and python_version < "4.0"
idna==3.4 ; python_version >= "3.8" and python_version < "4.0"
requests==2.28.2 ; python_version >= "3.8" and python_version < "4.0"
urllib3==1.26.15 ; python_version >= "3.8" and python_version < "4.0"
```

### 9. プロジェクトのビルドと公開

以下のコマンドを入力して実行してみましょう：

```bash
# プロジェクトをビルド
poetry build
```

実行結果：
```
Building my-python-project (0.1.0)
  - Building sdist
  - Building wheel
  - Built my-python-project-0.1.0.tar.gz
  - Built my_python_project-0.1.0-py3-none-any.whl
```

`dist`ディレクトリにビルドされたパッケージが生成されます。

### 10. まとめ

Poetryを使うことで、以下のようなPythonプロジェクト管理が容易になります：

- 依存関係の管理（追加・削除・更新）
- 仮想環境の自動作成と切り替え
- プロジェクトのパッケージ化と配布
- 開発環境と本番環境の依存関係の分離

これらの機能によって、よりクリーンで再現性の高いPython開発が可能になります。
