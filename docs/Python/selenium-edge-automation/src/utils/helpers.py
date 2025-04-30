import os
import time
from datetime import datetime


def take_screenshot(driver, name=None):
    """スクリーンショットを撮影して保存"""
    if not os.path.exists("screenshots"):
        os.makedirs("screenshots")

    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    screenshot_name = f"{name}_{timestamp}.png" if name else f"screenshot_{timestamp}.png"
    screenshot_path = os.path.join("screenshots", screenshot_name)

    driver.save_screenshot(screenshot_path)
    return screenshot_path


def wait_for(seconds):
    """明示的な待機（テスト目的でのみ使用）"""
    time.sleep(seconds)
