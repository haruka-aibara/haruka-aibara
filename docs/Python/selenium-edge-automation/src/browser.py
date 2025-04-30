from config.settings import EDGE_OPTIONS
from selenium import webdriver
from selenium.webdriver.edge.service import Service
from webdriver_manager.microsoft import EdgeChromiumDriverManager


class Browser:
    """Edgeブラウザセッションを管理するクラス"""

    def __init__(self):
        self.driver = None

    def start(self):
        """Edgeブラウザセッションを開始"""
        options = webdriver.EdgeOptions()

        if EDGE_OPTIONS["headless"]:
            options.add_argument("--headless")

        # その他の有用なオプション
        options.add_argument("--start-maximized")
        options.add_argument("--disable-extensions")
        options.add_argument("--disable-gpu")

        # ブラウザドライバーの自動ダウンロードとセットアップ
        service = Service(EdgeChromiumDriverManager().install())

        self.driver = webdriver.Edge(service=service, options=options)
        return self.driver

    def quit(self):
        """ブラウザセッションを終了"""
        if self.driver:
            self.driver.quit()
            self.driver = None
