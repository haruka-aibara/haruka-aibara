# pyenvの使い方ガイド

## 概要
pyenvはPythonのバージョン管理ツールで、複数のPythonバージョンを簡単に切り替えて使用できるようにします。

## 主要概念
pyenvはシステムのPATH環境変数を操作することで、異なるPythonのバージョンを切り替えて使用できるようにするツールです。

## インストール方法

### Linuxの場合

以下のコマンドを入力して実行してみましょう：

```bash
# 必要なパッケージをインストール
sudo apt-get update
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
xz-utils tk-dev libffi-dev liblzma-dev python-openssl git

# pyenvをインストール
curl https://pyenv.run | bash
```

実行結果：
上記コマンドを実行すると、pyenvとその関連ツールがインストールされます。

次に、シェル設定ファイルに以下の内容を追加する必要があります。以下のコマンドを入力して実行してみましょう：

```bash
# .bashrcに設定を追加
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc

# 設定を反映
source ~/.bashrc
```

実行結果：
これでpyenvのパスが設定され、コマンドが使えるようになります。

### macOSの場合

以下のコマンドを入力して実行してみましょう：

```bash
# Homebrewがない場合はインストール
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# pyenvをインストール
brew install pyenv

# .zshrcに設定を追加（zshの場合）
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init --path)"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc

# 設定を反映
source ~/.zshrc
```

実行結果：
これでpyenvのパスが設定され、コマンドが使えるようになります。

## pyenvの基本的な使い方

### 利用可能なPythonバージョンを確認

以下のコマンドを入力して実行してみましょう：

```bash
# インストール可能なPythonバージョンの一覧を表示
pyenv install --list
```

実行結果：
インストール可能なPythonのバージョン一覧が表示されます。非常に多くのバージョンが表示されるため、less等でスクロールするか、grepで検索するとよいでしょう。

### Pythonのインストール

以下のコマンドを入力して実行してみましょう：

```bash
# Python 3.9.7をインストール
pyenv install 3.9.7
```

実行結果：
指定したバージョンのPythonがインストールされます。インストール中はソースコードのダウンロードやコンパイルが行われるため、しばらく時間がかかります。

### インストール済みのバージョンを確認

以下のコマンドを入力して実行してみましょう：

```bash
# インストール済みのPythonバージョン一覧を表示
pyenv versions
```

実行結果：
インストール済みのPythonバージョンが表示されます。現在使用中のバージョンには「*」マークが付いています。

### Pythonのバージョンを切り替える

#### グローバルバージョンの設定

以下のコマンドを入力して実行してみましょう：

```bash
# システム全体のデフォルトPythonバージョンを3.9.7に設定
pyenv global 3.9.7

# 設定を確認
python --version
```

実行結果：
`Python 3.9.7`と表示されれば、バージョン切り替えが成功しています。

#### ローカルバージョンの設定

特定のディレクトリでのみ使用するPythonバージョンを設定できます。以下のコマンドを入力して実行してみましょう：

```bash
# 現在のディレクトリで使用するPythonバージョンを3.9.7に設定
pyenv local 3.9.7

# .python-versionファイルが作成されたことを確認
ls -la | grep python-version
```

実行結果：
`.python-version`というファイルが作成され、このディレクトリとそのサブディレクトリではPython 3.9.7が使用されます。

### 一時的なバージョン切り替え

以下のコマンドを入力して実行してみましょう：

```bash
# 現在のシェルセッションのみ一時的にPython 3.9.7を使用
pyenv shell 3.9.7

# 設定を確認
python --version
```

実行結果：
`Python 3.9.7`と表示され、現在のシェルセッション中のみPython 3.9.7が使用されます。

### バージョン設定の優先順位

pyenvは以下の優先順位でPythonバージョンを選択します：

1. `pyenv shell`で設定されたバージョン
2. `pyenv local`で設定されたバージョン（.python-versionファイル）
3. `pyenv global`で設定されたバージョン

## virtualenvとの連携（pyenv-virtualenv）

pyenv-virtualenvプラグインを使うと、pyenvとvirtualenvを統合して使用できます。

### pyenv-virtualenvのインストール

以下のコマンドを入力して実行してみましょう：

```bash
# pyenv-virtualenvプラグインをインストール（Linux/macOS）
git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv

# シェル設定ファイルに追加
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc  # bashの場合
# または
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc   # zshの場合

# 設定を反映
source ~/.bashrc  # bashの場合
# または
source ~/.zshrc   # zshの場合
```

実行結果：
pyenv-virtualenvプラグインがインストールされ、設定が追加されます。

### 仮想環境の作成

以下のコマンドを入力して実行してみましょう：

```bash
# Python 3.9.7を使用した「my-project」という名前の仮想環境を作成
pyenv virtualenv 3.9.7 my-project
```

実行結果：
指定したPythonバージョンを使用した仮想環境が作成されます。

### 仮想環境の有効化

以下のコマンドを入力して実行してみましょう：

```bash
# 仮想環境を有効化
pyenv activate my-project

# 確認
python --version
pip list
```

実行結果：
仮想環境が有効化され、プロンプトが変わります。`python --version`で使用中のPythonバージョンが表示され、`pip list`で仮想環境内にインストールされているパッケージが表示されます。

### 仮想環境の無効化

以下のコマンドを入力して実行してみましょう：

```bash
# 仮想環境を無効化
pyenv deactivate
```

実行結果：
仮想環境が無効化され、プロンプトが元に戻ります。

### ディレクトリに仮想環境を関連付ける

以下のコマンドを入力して実行してみましょう：

```bash
# プロジェクトディレクトリを作成して移動
mkdir my-python-project
cd my-python-project

# このディレクトリに仮想環境を関連付ける
pyenv local my-project
```

実行結果：
`.python-version`ファイルが作成され、このディレクトリとそのサブディレクトリでは自動的に`my-project`仮想環境が有効化されます。

## pyenvを使ったプロジェクト開発の実践例

以下のコマンドを入力して実行してみましょう：

```bash
# 新しいプロジェクトディレクトリを作成
mkdir pyenv-demo
cd pyenv-demo

# Python 3.9.7を使用した仮想環境を作成
pyenv virtualenv 3.9.7 pyenv-demo-env

# 現在のディレクトリに仮想環境を関連付け
pyenv local pyenv-demo-env

# 必要なパッケージをインストール
pip install requests pandas matplotlib

# requirements.txtを作成
pip freeze > requirements.txt

# 簡単なPythonスクリプトを作成
cat > app.py << 'EOF'
import requests
import pandas as pd
import matplotlib.pyplot as plt
import sys

def main():
    # Pythonのバージョンを表示
    print(f"Pythonのバージョン: {sys.version}")
    
    # インストール済みパッケージを表示
    print("\nインストール済みの主要パッケージ:")
    print(f"requests: {requests.__version__}")
    print(f"pandas: {pd.__version__}")
    
    print("\npyenvとvirtualenvを使った環境構築成功！")

if __name__ == "__main__":
    main()
EOF

# スクリプトを実行
python app.py
```

実行結果：
上記のコマンドを実行すると、以下のような出力が表示されます：

```
Pythonのバージョン: 3.9.7 (default, Sep 10 2021, 00:00:00) 
[GCC 4.2.1 Compatible Apple LLVM 12.0.0 (clang-1200.0.32.29) (-macos10.15-objc-

インストール済みの主要パッケージ:
requests: 2.28.1
pandas: 1.4.3

pyenvとvirtualenvを使った環境構築成功！
```

この実行結果から、pyenvを使って指定したPythonバージョンの環境が正しく設定され、必要なパッケージがインストールされたことが確認できます。

## まとめ

pyenvを使うことで、以下のことが可能になります：

1. 複数のPythonバージョンを簡単にインストール・管理できる
2. プロジェクトごとに異なるPythonバージョンを使用できる
3. virtualenvと組み合わせて、独立した開発環境を構築できる

pyenvはPythonの開発環境を柔軟に管理したい場合に非常に役立つツールです。
