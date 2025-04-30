from config.settings import BASE_URL
from selenium.webdriver.common.by import By
from src.utils.helpers import take_screenshot


def test_edge_example(browser):
    """Edgeブラウザでの基本的なテスト例"""
    # サイトに移動
    browser.get(BASE_URL)

    # ページタイトルを検証
    assert "Example" in browser.title

    # スクリーンショットを撮影
    take_screenshot(browser, "example_page")

    # 要素の検索と操作
    try:
        # 存在する要素の場合
        header = browser.find_element(By.TAG_NAME, "h1")
        assert header.text == "Example Domain"
    except:
        # テストが失敗した場合のスクリーンショット
        take_screenshot(browser, "test_failure")
        raise
