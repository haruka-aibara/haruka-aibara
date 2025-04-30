from config.settings import TIMEOUT
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait


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
