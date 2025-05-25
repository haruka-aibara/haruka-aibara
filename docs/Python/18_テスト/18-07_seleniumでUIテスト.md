# Python初心者のためのSelenium自動化入門

## 1. Seleniumとは

Seleniumはウェブブラウザの自動操作を可能にするツールで、Webアプリケーションのテスト自動化に広く利用されています。

## 2. Seleniumの基本概念

Seleniumは「WebDriver」というAPIを通じてChromeやEdgeなどのブラウザを制御し、実際のユーザー操作をプログラムで再現します。

## 3. 環境構築

まずは必要なパッケージをインストールしましょう：

```bash
# 仮想環境を作成（推奨）
python -m venv selenium-env
source selenium-env/bin/activate  # WindowsならActivate.ps1またはactivate.bat

# 必要なパッケージをインストール
pip install selenium webdriver-manager pytest
```

## 4. 基本的なプロジェクト構造

自動化プロジェクトの基本構造を作りましょう：

```
selenium-automation/
├── requirements.txt
├── config/
│   └── settings.py
├── src/
│   ├── __init__.py
│   ├── browser.py
│   └── page_objects/
│       ├── __init__.py
│       └── base_page.py
└── tests/
    ├── __init__.py
    ├── conftest.py
    └── test_example.py
```

各ファイルを以下の内容で作成します。

### requirements.txt
```
selenium==4.17.2
webdriver-manager==4.0.1
pytest==7.4.0
```

### config/settings.py
```python
# ブラウザ設定
BROWSER_OPTIONS = {
    "headless": False,  # ヘッドレスモード（画面表示なし）の有効/無効
}

# テスト対象のURL
BASE_URL = "https://www.example.com"

# 待機時間の設定（秒）
TIMEOUT = 10
```

### src/browser.py
```python
from selenium import webdriver
from selenium.webdriver.edge.service import Service
from webdriver_manager.microsoft import EdgeChromiumDriverManager
from config.settings import BROWSER_OPTIONS

class Browser:
    """ブラウザセッションを管理するクラス"""
    
    def __init__(self):
        self.driver = None
    
    def start(self):
        """Edgeブラウザセッションを開始"""
        # ブラウザオプションの設定
        options = webdriver.EdgeOptions()
        
        if BROWSER_OPTIONS["headless"]:
            options.add_argument("--headless")
        
        # その他の一般的なオプション
        options.add_argument("--start-maximized")  # 画面を最大化
        options.add_argument("--disable-extensions")  # 拡張機能を無効化
        
        # WebDriver Managerを使用して自動的にドライバーをダウンロード
        service = Service(EdgeChromiumDriverManager().install())
        
        # Edgeブラウザを起動
        self.driver = webdriver.Edge(service=service, options=options)
        return self.driver
    
    def quit(self):
        """ブラウザセッションを終了"""
        if self.driver:
            self.driver.quit()
            self.driver = None
```

### src/page_objects/base_page.py
```python
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from config.settings import TIMEOUT

class BasePage:
    """全てのページオブジェクトの基底クラス"""
    
    def __init__(self, driver):
        self.driver = driver
        self.wait = WebDriverWait(driver, TIMEOUT)
    
    def get_title(self):
        """ページのタイトルを取得"""
        return self.driver.title
    
    def navigate_to(self, url):
        """指定URLに移動"""
        self.driver.get(url)
    
    def find_element(self, locator):
        """要素を見つけて返す（待機付き）"""
        return self.wait.until(EC.presence_of_element_located(locator))
    
    def click(self, locator):
        """要素をクリック（待機付き）"""
        element = self.wait.until(EC.element_to_be_clickable(locator))
        element.click()
    
    def input_text(self, locator, text):
        """テキストを入力（待機付き）"""
        element = self.find_element(locator)
        element.clear()
        element.send_keys(text)
```

### tests/conftest.py
```python
import pytest
from src.browser import Browser

@pytest.fixture(scope="function")
def browser():
    """各テスト関数用のブラウザインスタンスを提供するフィクスチャ"""
    browser_instance = Browser()
    driver = browser_instance.start()
    
    # テスト関数にドライバーを渡す
    yield driver
    
    # テスト終了後にブラウザを閉じる
    browser_instance.quit()
```

### tests/test_example.py
```python
from selenium.webdriver.common.by import By
from config.settings import BASE_URL

def test_edge_example(browser):
    """基本的なSeleniumテスト例"""
    # サイトに移動
    browser.get(BASE_URL)
    
    # ページタイトルを検証
    assert "Example" in browser.title
    
    # 要素を検索して検証
    header = browser.find_element(By.TAG_NAME, "h1")
    assert header.text == "Example Domain"
    
    # コンソールに結果を表示
    print(f"ページタイトル: {browser.title}")
    print(f"見出し: {header.text}")
```

## 5. 実行する

プロジェクトを作成したら、以下のコマンドでテストを実行します：

```bash
pytest tests/
```

期待される出力：
```
collected 1 item

tests/test_example.py .  [100%]

================================== 1 passed in 5.32s ==================================
```

詳細出力を表示するには:

```bash
pytest -v tests/
```

期待される出力：
```
collected 1 item

tests/test_example.py::test_edge_example PASSED  [100%]

================================== 1 passed in 5.47s ==================================
```

## 6. トラブルシューティング

### WSL2 Ubuntuでの対応例

Edge ブラウザがないというエラーが出た場合は、以下の手順で対応します：

#### 1. 依存パッケージのインストール
```bash
sudo apt install libnss3-dev
```

#### 2. Microsoft Edgeをインストール
```bash
# Microsoftの署名キーを追加
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft-edge.gpg
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge.list'

# Edgeをインストール
sudo apt update
sudo apt install microsoft-edge-stable
```

## 7. 実践的な使用例

ここでは、Googleで検索を行う例を示します：

### google_search_test.py
```python
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
import time

def test_google_search(browser):
    """Google検索のテスト"""
    # Googleトップページに移動
    browser.get("https://www.google.com")
    
    # 検索ボックスを見つけて「Selenium Python」と入力
    search_box = browser.find_element(By.NAME, "q")
    search_box.send_keys("Selenium Python")
    
    # Enterキーを押して検索を実行
    search_box.send_keys(Keys.RETURN)
    
    # 結果が表示されるまで少し待機
    time.sleep(2)
    
    # 検索結果のタイトルを確認
    assert "Selenium Python" in browser.title
    
    # 検索結果の最初のリンクのテキストを取得
    results = browser.find_elements(By.CSS_SELECTOR, "h3")
    if results:
        print(f"最初の検索結果: {results[0].text}")
```

このテストは、Googleで「Selenium Python」を検索し、検索結果を確認します。

## 8. まとめ

Seleniumを使えば、ブラウザの操作を自動化し、Webアプリケーションのテストや様々な繰り返し作業を効率化できます。この基本的なプロジェクト構造をベースに、自分のプロジェクトに合わせてカスタマイズしてみましょう。
