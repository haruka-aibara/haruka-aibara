import os

import pytest
from src.browser import Browser


@pytest.fixture(scope="function")
def browser():
    """各テスト関数用のブラウザインスタンスを提供するフィクスチャ"""
    # 画面付きの Edge を手元で動かす前提のテストなので、CI では走らせない。
    if os.environ.get("CI"):
        pytest.skip("Edge を画面付きで起動するため CI では実行しない")
    browser_instance = Browser()
    driver = browser_instance.start()

    yield driver

    browser_instance.quit()
