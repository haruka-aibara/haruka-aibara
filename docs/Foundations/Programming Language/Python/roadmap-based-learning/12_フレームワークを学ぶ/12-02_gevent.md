# gevent入門

## 概要
geventは、協調的マルチタスクを実現するPythonのネットワークライブラリで、高性能な非同期I/O処理を簡潔な同期的コードで書けるようにします。

## 主要概念
geventはグリーンレット（軽量スレッド）とイベントループを利用して、ノンブロッキングI/Oを実現しながらも同期コードのように書けるコルーチンベースの並行処理を提供します。

## 1. インストール方法

まずはgeventをインストールしましょう。以下のコマンドを実行してください。

```bash
pip install gevent
```

## 2. 基本的な使い方

### 例1: 基本的なグリーンレット

以下のコードを入力して実行してみましょう。

```python
import gevent
import time

def task(name):
    """単純なタスク関数"""
    for i in range(3):
        print(f"{name}: {i}")
        # time.sleep()だとブロッキングされるので、gevent.sleep()を使用
        gevent.sleep(1)

# 3つのグリーンレットを生成
g1 = gevent.spawn(task, "タスク1")
g2 = gevent.spawn(task, "タスク2")
g3 = gevent.spawn(task, "タスク3")

# すべてのグリーンレットが完了するまで待機
gevent.joinall([g1, g2, g3])
```

**実行結果**:
```
タスク1: 0
タスク2: 0
タスク3: 0
タスク1: 1
タスク2: 1
タスク3: 1
タスク1: 2
タスク2: 2
タスク3: 2
```

**解説**:
この例では、3つのグリーンレットを作成し、それぞれに`task`関数を実行させています。各タスクは0から2までのカウントを行い、各カウントの間に1秒の待機時間があります。`gevent.sleep()`を使うことで、そのグリーンレットは一時停止し、他のグリーンレットに実行権が移ります。

`gevent.spawn()`は新しいグリーンレットを作成し、`gevent.joinall()`はすべてのグリーンレットが完了するまで待機するために使用されます。

## 3. モンキーパッチング

geventの強力な機能の一つに「モンキーパッチング」があります。これは標準ライブラリの関数をgeventの非同期バージョンに置き換える機能です。

### 例2: モンキーパッチングの利用

以下のコードを入力して実行してみましょう。

```python
# 最初にモンキーパッチングを行う
from gevent import monkey
monkey.patch_all()

import gevent
import requests
import time

def fetch_url(url):
    """URLからデータを取得する関数"""
    print(f"{url}の取得を開始しました - {time.strftime('%H:%M:%S')}")
    response = requests.get(url)
    print(f"{url}から{len(response.content)}バイトを取得しました - {time.strftime('%H:%M:%S')}")
    return response.content

# 取得するURLのリスト
urls = [
    'https://www.python.org/',
    'https://www.google.com/',
    'https://www.github.com/'
]

# 同期的に実行
print("同期的に実行:")
start = time.time()
for url in urls:
    fetch_url(url)
print(f"同期実行の所要時間: {time.time() - start:.2f}秒\n")

# 非同期的に実行
print("非同期的に実行:")
start = time.time()
jobs = [gevent.spawn(fetch_url, url) for url in urls]
gevent.joinall(jobs)
print(f"非同期実行の所要時間: {time.time() - start:.2f}秒")
```

**実行結果** (時間や取得サイズは実行環境により異なります):
```
同期的に実行:
https://www.python.org/の取得を開始しました - 12:34:56
https://www.python.org/から51234バイトを取得しました - 12:34:57
https://www.google.com/の取得を開始しました - 12:34:57
https://www.google.com/から15678バイトを取得しました - 12:34:58
https://www.github.com/の取得を開始しました - 12:34:58
https://www.github.com/から42567バイトを取得しました - 12:34:59
同期実行の所要時間: 3.45秒

非同期的に実行:
https://www.python.org/の取得を開始しました - 12:34:59
https://www.google.com/の取得を開始しました - 12:34:59
https://www.github.com/の取得を開始しました - 12:34:59
https://www.google.com/から15678バイトを取得しました - 12:35:00
https://www.python.org/から51234バイトを取得しました - 12:35:00
https://www.github.com/から42567バイトを取得しました - 12:35:00
非同期実行の所要時間: 1.23秒
```

**解説**:
この例では、まず`monkey.patch_all()`を呼び出してPythonの標準ライブラリをgeventの非同期バージョンに置き換えています。これにより、標準の`time.sleep()`や`requests.get()`などがブロッキングI/O操作でも、geventがそれを非同期的に処理できるようになります。

コードでは3つのウェブサイトから同期的に取得する場合と、geventを使って非同期的に取得する場合の速度差を比較しています。非同期バージョンは複数のリクエストを並行して実行するため、全体の実行時間が短くなります。

## 4. グリーンレットの通信

### 例3: イベントを使った通信

以下のコードを入力して実行してみましょう。

```python
import gevent
from gevent.event import Event

# イベントオブジェクトを作成
event = Event()

def waiter():
    """イベントが設定されるのを待機するグリーンレット"""
    print('待機を開始します...')
    event.wait()  # イベントが設定されるまでブロック
    print('イベントが設定されました。処理を続行します。')

def setter():
    """3秒後にイベントを設定するグリーンレット"""
    print('3秒後にイベントを設定します...')
    gevent.sleep(3)
    print('イベントを設定します!')
    event.set()

# グリーンレットを生成して実行
gevent.joinall([
    gevent.spawn(waiter),
    gevent.spawn(setter),
])
```

**実行結果**:
```
待機を開始します...
3秒後にイベントを設定します...
イベントを設定します!
イベントが設定されました。処理を続行します。
```

**解説**:
この例では、`Event`オブジェクトを使用してグリーンレット間の通信を行っています。`waiter`グリーンレットは`event.wait()`でイベントが設定されるまで待機し、`setter`グリーンレットは3秒後に`event.set()`でイベントを設定します。この仕組みにより、グリーンレット間での同期処理が可能になります。

## 5. 複数のタスクを効率的に処理

### 例4: gevent.poolの使用

以下のコードを入力して実行してみましょう。

```python
import gevent
from gevent.pool import Pool
import time

def process_task(task_id):
    """何らかの処理を行うタスク"""
    print(f"タスク {task_id} を開始します")
    # 処理時間をシミュレート（タスクIDによって処理時間が異なる）
    gevent.sleep(task_id * 0.5)
    print(f"タスク {task_id} を完了しました")
    return task_id * 10  # 何らかの結果を返す

# 最大2つの並行タスクを処理するプールを作成
pool = Pool(2)
start_time = time.time()

# 5つのタスクをプールに追加
tasks = list(range(1, 6))  # タスク1から5
results = pool.map(process_task, tasks)

print(f"\nすべてのタスクが完了しました。所要時間: {time.time() - start_time:.2f}秒")
print(f"結果: {results}")
```

**実行結果**:
```
タスク 1 を開始します
タスク 2 を開始します
タスク 1 を完了しました
タスク 3 を開始します
タスク 2 を完了しました
タスク 4 を開始します
タスク 3 を完了しました
タスク 5 を開始します
タスク 4 を完了しました
タスク 5 を完了しました

すべてのタスクが完了しました。所要時間: 6.50秒
結果: [10, 20, 30, 40, 50]
```

**解説**:
この例では、`Pool`を使用して一度に実行できるグリーンレットの数を制限しています。サイズ2のプールを作成したため、一度に最大2つのタスクだけが並行して実行されます。

`pool.map()`は指定した関数を各アイテムに対して適用し、その結果をリストとして返します。この例では、処理時間が異なる5つのタスクを2つずつ実行していくため、タスク1と2が先に実行され、タスク1が完了するとすぐにタスク3が開始されるという流れになります。

プールを使うことで、リソース使用量を制御しながら効率的に並行処理を行うことができます。

## 6. タイムアウト処理

### 例5: タイムアウトの実装

以下のコードを入力して実行してみましょう。

```python
import gevent
from gevent import Timeout

def long_running_task():
    """時間のかかるタスク"""
    print("長時間実行タスクを開始します")
    gevent.sleep(5)  # 5秒かかる処理
    print("長時間実行タスクが完了しました") # このメッセージは表示されないはず

def handle_timeout():
    """タイムアウト処理"""
    try:
        # 2秒のタイムアウトを設定
        with Timeout(2, TimeoutError("処理がタイムアウトしました")):
            long_running_task()
    except TimeoutError as e:
        print(f"エラー: {e}")
        # タイムアウト後の処理を行う
        print("タイムアウト後の代替処理を実行します")

# タイムアウトを実装したグリーンレットを実行
gevent.spawn(handle_timeout).join()
```

**実行結果**:
```
長時間実行タスクを開始します
エラー: 処理がタイムアウトしました
タイムアウト後の代替処理を実行します
```

**解説**:
この例では、`Timeout`クラスを使用してタスクの最大実行時間を制限しています。`long_running_task`関数は5秒かかる処理ですが、`Timeout`によって2秒後にタイムアウトが発生し、例外が投げられます。

`with`ステートメントと組み合わせることで、そのブロック内の処理に対してタイムアウトを設定できます。タイムアウトが発生すると`TimeoutError`例外が発生し、それをcatchして代替処理を実行できます。

## 7. HTTPサーバーの実装

### 例6: geventを使ったシンプルなHTTPサーバー

以下のコードを入力して実行してみましょう。

```python
from gevent import monkey
monkey.patch_all()

from gevent.pywsgi import WSGIServer

def application(environ, start_response):
    """WSGIアプリケーション"""
    path = environ['PATH_INFO']
    status = '200 OK'
    headers = [('Content-Type', 'text/html; charset=utf-8')]
    start_response(status, headers)
    
    if path == '/':
        return [b"<h1>geventで作成したウェブサーバーへようこそ!</h1>"]
    elif path == '/about':
        return [b"<h1>これはgeventのデモサーバーです</h1>"]
    else:
        return [f"<h1>要求されたパス: {path}</h1>".encode('utf-8')]

if __name__ == '__main__':
    # ポート8000でHTTPサーバーを起動
    print('サーバーを起動します http://127.0.0.1:8000')
    server = WSGIServer(('127.0.0.1', 8000), application)
    
    try:
        # サーバーを永続的に実行（Ctrl+Cで停止）
        server.serve_forever()
    except KeyboardInterrupt:
        print('サーバーを停止します')
```

**実行方法と試し方**:
1. このコードを実行します
2. ブラウザで `http://127.0.0.1:8000` にアクセスしてみましょう
3. また、`http://127.0.0.1:8000/about` や他のパスにもアクセスしてみましょう
4. サーバーを停止するには、コンソールで `Ctrl+C` を押します

**解説**:
この例では、geventのWSGIサーバー実装を使用して簡単なウェブサーバーを作成しています。`WSGIServer`クラスはPythonのWSGI仕様に準拠したHTTPサーバーです。このサーバーはgeventのグリーンレットを使用して並行してリクエストを処理するため、効率的に多くの接続を扱うことができます。

`application`関数はWSGIアプリケーションで、各HTTPリクエストに対して呼び出されます。この例では、リクエストパスに応じて異なるレスポンスを返す簡単なルーティングを実装しています。

## まとめ

geventは、簡潔で読みやすいコードを保ちながらも高性能な非同期I/O処理を実現できる強力なライブラリです。グリーンレットというライトウェイトな仮想スレッドを使い、協調的マルチタスクを実現します。以下が主なポイントです：

1. **グリーンレット**: 軽量スレッドを使った協調的マルチタスク
2. **モンキーパッチング**: 既存のブロッキングコードを非同期化
3. **イベント**: グリーンレット間の通信と同期
4. **プール**: 並行実行数の制限によるリソース管理
5. **タイムアウト**: 長時間実行タスクの制御
6. **HTTPサーバー**: スケーラブルなウェブアプリケーションの構築

geventの特長は、複雑な非同期コードや、コールバック地獄を避けながらも効率的な並行処理を書けることです。特にI/O待ちの多いネットワークアプリケーションやウェブアプリケーションの開発に最適です。
