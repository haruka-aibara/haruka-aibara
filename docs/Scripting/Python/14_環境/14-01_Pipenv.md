# Pipenv 環境管理入門

## 概要
Pipenvは、Python開発において依存関係管理とパッケージ管理を簡素化するツールで、仮想環境の作成と管理を効率化します。

## Pipenvの基本概念
Pipenvは`pip`と`virtualenv`の機能を組み合わせ、単一のコマンドラインツールで依存関係管理とプロジェクト分離を実現します。

## Pipenvのインストールと基本操作

### 1. Pipenvのインストール

まずはPipenvをインストールしましょう。以下のコマンドを入力して実行してください：

```bash
# Pipenvのインストール
pip install pipenv
```

実行結果：
```
Collecting pipenv
  ...（ダウンロードと依存関係のインストール情報）
Successfully installed pipenv-2023.x.x ...（その他のパッケージ情報）
```

### 2. プロジェクトの初期化

新しいプロジェクトディレクトリを作成し、Pipenvを初期化します。以下のコマンドを入力して実行してみましょう：

```bash
# プロジェクトディレクトリの作成
mkdir pipenv_sample
cd pipenv_sample

# Pipenvの初期化
pipenv --python 3.9
```

実行結果：
```
Creating a virtualenv for this project...
Using /usr/local/bin/python3.9 to create virtualenv...
⠋ Creating virtual environment...
✔ Successfully created virtual environment!
...
```

### 3. パッケージのインストール

プロジェクトに必要なパッケージをインストールします。以下のコマンドを入力して実行してみましょう：

```bash
# requestsパッケージをインストール
pipenv install requests
```

実行結果：
```
Installing requests...
Adding requests to Pipfile's [packages]...
✔ Installation Succeeded
...
```

### 4. 開発用パッケージのインストール

開発中のみ必要なパッケージは、`--dev`フラグを使用してインストールします。以下のコマンドを入力して実行してみましょう：

```bash
# pytestを開発用パッケージとしてインストール
pipenv install pytest --dev
```

実行結果：
```
Installing pytest...
Adding pytest to Pipfile's [dev-packages]...
✔ Installation Succeeded
...
```

### 5. 仮想環境内でのコマンド実行

Pipenv環境内でPythonスクリプトやコマンドを実行する方法です。以下のコマンドを入力して実行してみましょう：

```bash
# Pipenv環境内でPythonを実行
pipenv run python -c "import requests; print(requests.__version__)"
```

実行結果：
```
2.31.0  # バージョンは異なる場合があります
```

### 6. Pipenv環境のシェルに入る

長時間作業する場合は、Pipenv環境のシェルに入ると便利です。以下のコマンドを入力して実行してみましょう：

```bash
# Pipenv環境のシェルを起動
pipenv shell
```

実行結果：
```
Launching subshell in virtual environment...
(pipenv_sample) $
```

シェル内では、直接Pythonコマンドを実行できます：

```bash
# シェル内での実行例
python -c "import requests; print('requestsのバージョン:', requests.__version__)"
```

実行結果：
```
requestsのバージョン: 2.31.0  # バージョンは異なる場合があります
```

### 7. 依存関係の確認

インストールされているパッケージとその依存関係を確認できます。以下のコマンドを入力して実行してみましょう：

```bash
# 依存関係をグラフで表示
pipenv graph
```

実行結果：
```
requests==2.31.0
  - certifi [required: >=2017.4.17, installed: 2023.7.22]
  - charset-normalizer [required: >=2,<4, installed: 3.2.0]
  - idna [required: >=2.5,<4, installed: 3.4]
  - urllib3 [required: >=1.21.1,<3, installed: 2.0.4]
...
```

### 8. Pipfileとlockファイル

Pipenvは`Pipfile`と`Pipfile.lock`という2つのファイルで依存関係を管理します。`Pipfile`を確認してみましょう：

```bash
# Pipfileの内容を表示
cat Pipfile
```

実行結果：
```
[[source]]
url = "https://pypi.org/simple"
verify_ssl = true
name = "pypi"

[packages]
requests = "*"

[dev-packages]
pytest = "*"

[requires]
python_version = "3.9"
```

### 9. 環境の再現

`Pipfile.lock`を使用して同じ環境を別のマシンで再現できます。以下のコマンドを入力して実行してみましょう：

```bash
# lockファイルから環境を再現する
pipenv install --ignore-pipfile
```

実行結果：
```
Installing dependencies from Pipfile.lock...
...
```

### 10. パッケージのアンインストール

不要になったパッケージをアンインストールするには以下のコマンドを使用します：

```bash
# パッケージのアンインストール
pipenv uninstall requests
```

実行結果：
```
Uninstalling requests...
Removing requests from Pipfile...
...
```

## プロジェクト例：シンプルなWebスクレイピング

実際のプロジェクトでPipenvを使う例として、シンプルなWebスクレイピングスクリプトを作成してみましょう。以下のコマンドとコードを入力して実行してみましょう：

```bash
# 必要なパッケージをインストール
pipenv install requests beautifulsoup4
```

次に、`scraper.py`というファイルを作成し、以下のコードを書いてみましょう：

```python
# scraper.py - シンプルなWebスクレイピング例
import requests
from bs4 import BeautifulSoup

# Webページを取得
url = 'https://www.python.org/'
response = requests.get(url)

# ステータスコードの確認
print(f'ステータスコード: {response.status_code}')

# BeautifulSoupでHTMLを解析
soup = BeautifulSoup(response.text, 'html.parser')

# タイトルを抽出
title = soup.title.string
print(f'ページタイトル: {title}')

# 最新ニュースのリンクを抽出（例）
news_items = soup.select('.blog-widget a')
print('\n最新情報:')
for i, item in enumerate(news_items[:5], 1):  # 最初の5項目だけ表示
    print(f'{i}. {item.text.strip()}')
```

このスクリプトを実行してみましょう：

```bash
# Pipenv環境内でスクリプトを実行
pipenv run python scraper.py
```

実行結果：
```
ステータスコード: 200
ページタイトル: Welcome to Python.org
最新情報:
1. Python 3.12.0 リリース
2. Python Software Foundation News
3. 2023 年度 Python デベロッパーサーベイ
...
```

以上がPipenvの基本的な使い方です。Pipenvを使うことで、プロジェクトごとに独立した環境を簡単に作成・管理できるようになります。
