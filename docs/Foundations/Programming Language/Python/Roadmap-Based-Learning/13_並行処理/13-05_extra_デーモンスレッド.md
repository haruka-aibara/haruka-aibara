# Pythonデーモンスレッド講義

## 概要
デーモンスレッドはメインプログラムが終了すると自動的に終了する特殊なスレッドで、バックグラウンド処理に最適です。

## 理論的説明
通常のスレッドはメインプログラムが終了しても実行が完了するまで待機しますが、デーモンスレッドはメインプログラムの終了と共に強制終了します。

## コード例と実行方法

以下のコード例を通じて、デーモンスレッドの動作を確認していきましょう。

### 例1: デーモンスレッドの基本動作

このコードを入力して実行してみましょう：

```python
import logging
import threading
import time

# ログの設定（スレッド名とメッセージを表示）
logging.basicConfig(level=logging.DEBUG, format="%(threadName)s: %(message)s")


def worker1():
    logging.debug("スタート")
    time.sleep(5)  # 5秒間処理を停止
    logging.debug("終了")  # この行は実行されない可能性があります


def worker2():
    logging.debug("スタート")
    time.sleep(5)  # 5秒間処理を停止
    logging.debug("終了")


if __name__ == "__main__":
    # worker1を実行するスレッドを作成しデーモン化
    t1 = threading.Thread(target=worker1)
    t1.daemon = True  # このスレッドをデーモンスレッドに設定
    
    # worker2を実行する通常のスレッドを作成
    t2 = threading.Thread(target=worker2)
    
    # 両方のスレッドを開始
    t1.start()
    t2.start()
    
    print("スレッド開始完了")
    
    # t1（デーモンスレッド）の終了を待機
    t1.join()
```

### 実行結果
```
Thread-1: スタート
Thread-2: スタート
スレッド開始完了
Thread-1: 終了
Thread-2: 終了
```

### 解説
このコードでは、2つのスレッドを作成しています：
- `t1`: `worker1`関数を実行するデーモンスレッド（`daemon=True`）
- `t2`: `worker2`関数を実行する通常のスレッド

`t1.join()`を呼び出すことで、メインスレッドはデーモンスレッド`t1`の終了を待ちます。このため、両方のスレッドが5秒間のスリープを終え、「終了」メッセージを表示して完了することができます。

### 例2: デーモンスレッドの自動終了

次に、`join()`メソッドを使わない場合の動作を確認してみましょう：

```python
import logging
import threading
import time

# ログの設定
logging.basicConfig(level=logging.DEBUG, format="%(threadName)s: %(message)s")


def worker1():
    logging.debug("スタート")
    time.sleep(5)  # 5秒間処理を停止
    logging.debug("終了")  # この行は実行されない


def worker2():
    logging.debug("スタート")
    time.sleep(2)  # 2秒間処理を停止
    logging.debug("終了")


if __name__ == "__main__":
    # worker1を実行するデーモンスレッドを作成
    t1 = threading.Thread(target=worker1)
    t1.daemon = True  # このスレッドをデーモンスレッドに設定
    
    # worker2を実行する通常のスレッドを作成
    t2 = threading.Thread(target=worker2)
    
    # 両方のスレッドを開始
    t1.start()
    t2.start()
    
    print("スレッド開始完了")
    
    # t2（通常スレッド）の終了を待機
    t2.join()
    
    print("メイン処理終了")
```

### 実行結果
```
Thread-1: スタート
Thread-2: スタート
スレッド開始完了
Thread-2: 終了
メイン処理終了
```

### 解説
このコードでは、`t1`（デーモンスレッド）の終了を待たずに、`t2`（通常スレッド）の終了のみを待ちます。`t2`は2秒後に終了するため、メインスレッドは約2秒後に終了します。

重要なポイントは、`t1`（デーモンスレッド）は5秒のスリープが完了する前にプログラム全体が終了するため、「終了」メッセージが表示されないことです。これがデーモンスレッドの特徴で、メインプログラムが終了すると自動的に終了します。

### 例3: タイムアウトの設定

`join()`メソッドにタイムアウトを設定することもできます：

```python
import logging
import threading
import time

# ログの設定
logging.basicConfig(level=logging.DEBUG, format="%(threadName)s: %(message)s")


def worker1():
    logging.debug("スタート")
    time.sleep(10)  # 10秒間処理を停止
    logging.debug("終了")


if __name__ == "__main__":
    # worker1を実行するデーモンスレッドを作成
    t1 = threading.Thread(target=worker1)
    t1.daemon = True  # このスレッドをデーモンスレッドに設定
    
    # スレッドを開始
    t1.start()
    
    print("スレッド開始完了")
    
    # 3秒間だけデーモンスレッドの終了を待機
    t1.join(3)
    
    print("メイン処理終了")
```

### 実行結果
```
Thread-1: スタート
スレッド開始完了
メイン処理終了
```

### 解説
このコードでは、`t1.join(3)`で3秒間だけデーモンスレッドの終了を待ちます。デーモンスレッドは10秒のスリープを行うため、3秒後にメインスレッドは待機をやめて処理を続行します。その結果、デーモンスレッドは「終了」メッセージを表示する前にプログラム全体が終了します。

## まとめ

デーモンスレッドの特徴：
1. メインプログラムが終了すると自動的に終了する
2. バックグラウンド処理やモニタリングに適している
3. `daemon=True`で設定可能
4. `join()`メソッドでデーモンスレッドの終了を待つことができる
5. `join(timeout)`でタイムアウトを設定できる

これらの例を通じて、デーモンスレッドの基本的な動作と使い方を理解できたでしょう。実際のアプリケーションでは、定期的なバックグラウンド処理やリソースモニタリングなどにデーモンスレッドが活用されています。
