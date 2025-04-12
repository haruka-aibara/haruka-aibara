import pytest
from src.browser import Browser


@pytest.fixture(scope="function")
def browser():
    """各テスト関数用のブラウザインスタンスを提供するフィクスチャ"""
    browser_instance = Browser()
    driver = browser_instance.start()

    yield driver

    browser_instance.quit()
