### 追加の拡張機能をインストール

 - Python
   - https://marketplace.visualstudio.com/items?itemName=ms-python.python

 - Ruff
   - https://marketplace.visualstudio.com/items?itemName=charliermarsh.ruff

### Settings.json を編集する

#### Ruff 用
https://qiita.com/LaserBit/items/8dfd410ef65c19053ce2
```
    "[python]": {
        "editor.codeActionsOnSave": {
            "source.fixAll": "explicit",
            "source.organizeImports": "explicit"
        },
        "editor.defaultFormatter": "charliermarsh.ruff"
    },
    "ruff.lineLength": 120,
    "ruff.lint.ignore": [
        "F401"
    ],
    "ruff.lint.preview": true,
    "ruff.lint.select": [
        "C",
        "E",
        "F",
        "W",
        "I"
    ],
    "ruff.logFile": "~/logs/ruff.log",
    "ruff.logLevel": "debug",
    "ruff.nativeServer": "on",
```

### Python 関連設定
https://docs.astral.sh/uv/getting-started/installation/

https://qiita.com/LaserBit/items/8dfd410ef65c19053ce2

uv インストール
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

```bash
source $HOME/.cargo/env
```

ruff 有効化
```bash
uv tool install ruf
uv tool update-shell
```

## Linux 版 Anaconda インストール
https://www.anaconda.com/download/success から最新の 64-bit Installer
参考：https://www.salesanalytics.co.jp/datascience/datascience141/#LinuxAnaconda

2025-03-30 時点の最新

wget https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh

bash Anaconda3-2024.10-1-Linux-x86_64.sh

source .bashrc

conda config --set auto_activate_base false

eval "$(/home/haruka_aibara/anaconda3/bin/conda shell.bash hook)" 

conda install anaconda-navigator

### 必要なライブラリのインストール（apt-get）
sudo apt-get update
sudo apt-get install \
    libpci3 \
    libgl1-mesa-glx \
    libegl1-mesa \
    libxrandr2 \
    libxss1 \
    libxcursor1 \
    libxcomposite1 \
    libasound2 \
    libxi6 \
    libxtst6 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libx11-xcb-dev \
    libglu1-mesa-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libxcb-xinerama0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-xkb1 \
    '^libxcb.*-dev'

### Conda関連のインストール
conda install -c anaconda qt qtpy
conda install -c conda-forge qt

### デバッグ用の環境変数設定（必要な場合のみ）
export QT_DEBUG_PLUGINS=1

これで、VSCode のターミナルで「anaconda-navigator」と入力すると
anaconda-navigator が起動します。


### Mypy Type Checker
https://marketplace.visualstudio.com/items/?itemName=ms-python.mypy-type-checker

### pip
sudo apt install python3-pip
