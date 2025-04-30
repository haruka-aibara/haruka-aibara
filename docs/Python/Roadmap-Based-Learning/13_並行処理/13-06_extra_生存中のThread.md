# Pythonで生存中のThreadオブジェクトリスト取得

## 概要
マルチスレッドプログラミングでは、実行中のスレッドを管理・監視する必要があります。`threading.enumerate()`関数を使うと、現在生存中のすべてのThreadオブジェクトのリストを取得できます。

## 基本概念
Pythonのスレッドは`threading`モジュールで管理され、`threading.enumerate()`関数を使用することで現在アクティブなスレッドのリストを取得できます。

## 実践コード例

### 例1: 基本的なスレッド列挙

以下のコードを入力して実行してみましょう。複数のスレッドを作成し、生存中のスレッドを列挙します。

```python
import logging
import threading
import time

# ログの設定
logging.basicConfig(level=logging.DEBUG, format="%(threadName)s: %(message)s")

def worker():
    """単純なワーカー関数"""
    logging.debug("開始")
    time.sleep(3)  # 3秒間スリープ
    logging.debug("終了")

if __name__ == "__main__":
    # メインスレッドの名前を設定
    threading.current_thread().name = "MainThread"
    
    # 3つのスレッドを作成して開始
    for i in range(3):
        t = threading.Thread(target=worker, name=f"Worker-{i}")
        t.start()
    
    # 少し待ってから生存中のスレッドを列挙
    time.sleep(1)
    
    logging.debug("現在生存中のスレッド一覧:")
    for thread in threading.enumerate():
        logging.debug(f"- {thread.name} (デーモン: {thread.daemon})")
```

**実行結果**:
```
MainThread: 現在生存中のスレッド一覧:
MainThread: - MainThread (デーモン: False)
MainThread: - Worker-0 (デーモン: False)
MainThread: - Worker-1 (デーモン: False)
MainThread: - Worker-2 (デーモン: False)
Worker-0: 開始
Worker-1: 開始
Worker-2: 開始
Worker-0: 終了
Worker-1: 終了
Worker-2: 終了
```

### 例2: デーモンスレッドとスレッド操作

次のコードを入力して実行してみましょう。デーモンスレッドを作成し、特定のスレッドを操作します。

```python
import logging
import threading
import time

# ログの設定
logging.basicConfig(level=logging.DEBUG, format="%(threadName)s: %(message)s")

def worker1():
    """通常のワーカー関数"""
    logging.debug("開始")
    time.sleep(5)
    logging.debug("終了")

def worker2():
    """別のワーカー関数"""
    logging.debug("開始")
    time.sleep(5)
    logging.debug("終了")

if __name__ == "__main__":
    # メインスレッドの名前を設定
    threading.current_thread().name = "MainThread"
    
    # デーモンスレッドを5つ作成
    for i in range(5):
        t = threading.Thread(target=worker1, name=f"Daemon-{i}")
        t.daemon = True  # デーモンスレッドに設定
        t.start()
    
    # 通常スレッドを2つ作成
    for i in range(2):
        t = threading.Thread(target=worker2, name=f"Normal-{i}")
        t.start()
    
    # スレッド一覧を取得して結合
    logging.debug("現在生存中のスレッド一覧:")
    for thread in threading.enumerate():
        logging.debug(f"- {thread.name} (デーモン: {thread.daemon})")
        
        # メインスレッド自身は結合しない
        if thread is threading.current_thread():
            logging.debug(f"  -> これはメインスレッドなのでjoin()しません")
            continue
            
        # 通常スレッドのみjoin（デーモンスレッドはメインスレッド終了と共に終了する）
        if not thread.daemon:
            logging.debug(f"  -> 通常スレッドなのでjoin()します")
            thread.join()
    
    logging.debug("メインスレッド終了")
```

**実行結果**:
```
MainThread: 現在生存中のスレッド一覧:
MainThread: - MainThread (デーモン: False)
MainThread: - Daemon-0 (デーモン: True)
MainThread: - Daemon-1 (デーモン: True)
MainThread: - Daemon-2 (デーモン: True)
MainThread: - Daemon-3 (デーモン: True)
MainThread: - Daemon-4 (デーモン: True)
MainThread: - Normal-0 (デーモン: False)
MainThread: - Normal-1 (デーモン: False)
MainThread:   -> これはメインスレッドなのでjoin()しません
MainThread:   -> 通常スレッドなのでjoin()します
Daemon-0: 開始
Daemon-1: 開始
Daemon-2: 開始
Daemon-3: 開始
Daemon-4: 開始
Normal-0: 開始
Normal-1: 開始
Normal-0: 終了
MainThread:   -> 通常スレッドなのでjoin()します
Normal-1: 終了
MainThread: メインスレッド終了
```

### 例3: 課題のコード例

以下は課題で指定されたコードを改良したものです。このコードを入力して実行してみましょう。

```python
import logging
import threading
import time

# ログの設定
logging.basicConfig(level=logging.DEBUG, format="%(threadName)s: %(message)s")

def worker1():
    """ワーカー関数1"""
    logging.debug("開始")
    time.sleep(5)
    logging.debug("終了")

def worker2():
    """ワーカー関数2"""
    logging.debug("開始")
    time.sleep(5)
    logging.debug("終了")

if __name__ == "__main__":
    # メインスレッドの名前を設定
    threading.current_thread().name = "MainThread"
    logging.debug("プログラム開始")
    
    # 5つのデーモンスレッドを作成
    for i in range(5):
        t = threading.Thread(target=worker1, name=f"DaemonThread-{i}")
        t.daemon = True  # デーモンスレッドに設定
        t.start()
        logging.debug(f"スレッド {t.name} を開始しました")
    
    # 現在生存中のスレッドを列挙
    logging.debug("現在生存中のスレッド一覧:")
    for thread in threading.enumerate():
        if thread is threading.current_thread():
            logging.debug(f"- {thread.name} (現在のスレッド)")
            continue
        logging.debug(f"- {thread.name} (デーモン: {thread.daemon})")
        # デーモンでないスレッドならjoin
        if not thread.daemon:
            thread.join()
    
    logging.debug("メインスレッド終了")
```

**実行結果**:
```
MainThread: プログラム開始
MainThread: スレッド DaemonThread-0 を開始しました
DaemonThread-0: 開始
MainThread: スレッド DaemonThread-1 を開始しました
DaemonThread-1: 開始
MainThread: スレッド DaemonThread-2 を開始しました
DaemonThread-2: 開始
MainThread: スレッド DaemonThread-3 を開始しました
DaemonThread-3: 開始
MainThread: スレッド DaemonThread-4 を開始しました
DaemonThread-4: 開始
MainThread: 現在生存中のスレッド一覧:
MainThread: - MainThread (現在のスレッド)
MainThread: - DaemonThread-0 (デーモン: True)
MainThread: - DaemonThread-1 (デーモン: True)
MainThread: - DaemonThread-2 (デーモン: True)
MainThread: - DaemonThread-3 (デーモン: True)
MainThread: - DaemonThread-4 (デーモン: True)
MainThread: メインスレッド終了
```

## まとめ

- `threading.enumerate()`関数を使うと現在アクティブなすべてのスレッドのリストを取得できます
- メインスレッドを含むすべての生存中のスレッドが取得できます
- `threading.current_thread()`で現在実行中のスレッドオブジェクトを取得できます
- デーモンスレッドはプログラム終了時に強制終了しますが、通常スレッドはプログラム終了を防ぎます
- `join()`メソッドを使うとスレッドの終了を待つことができます

これらの知識を活用することで、複雑なマルチスレッドプログラムの管理と監視が可能になります。
