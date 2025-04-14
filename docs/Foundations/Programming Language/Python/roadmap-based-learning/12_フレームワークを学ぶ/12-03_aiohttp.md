# Python非同期通信ライブラリ「aiohttp」

## 概要
aiohttpは、Python用の非同期HTTP通信ライブラリで、asyncioを活用した高性能なHTTPクライアントとサーバー機能を提供します。

## 主要概念
aiohttpは「asyncio」を基盤とし、ノンブロッキングI/Oを使って複数のHTTPリクエストを効率的に処理できます。

## 実践編：step by step

### 1. インストール

まず、aiohttpをインストールします。以下のコマンドを実行してください。

```bash
pip install aiohttp
```

### 2. 基本的なHTTPリクエスト

最初に、シンプルなHTTPリクエストを送信してみましょう。

```python
import aiohttp
import asyncio

async def fetch_data(url):
    # セッションの作成
    async with aiohttp.ClientSession() as session:
        # GETリクエストの送信
        async with session.get(url) as response:
            # レスポンスのステータスコードを表示
            print(f"ステータスコード: {response.status}")
            # レスポンスの内容をJSONとして取得
            return await response.json()

async def main():
    # JSONPlaceholderの無料APIを使用
    url = "https://jsonplaceholder.typicode.com/posts/1"
    data = await fetch_data(url)
    print(f"取得したデータ: {data}")

# イベントループの実行
asyncio.run(main())
```

このコードを入力して実行してみましょう。以下のような出力が表示されるはずです：

```
ステータスコード: 200
取得したデータ: {'userId': 1, 'id': 1, 'title': 'sunt aut facere repellat provident occaecati excepturi optio reprehenderit', 'body': 'quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto'}
```

**解説**:
- `aiohttp.ClientSession`を使用してHTTPセッションを作成します
- `async with`文を使って、リソースを適切に管理します
- `response.json()`はレスポンスの内容をJSONとして解析します
- `asyncio.run()`で非同期関数を実行します

### 3. 複数のリクエストを並行処理

aiohttpの真価は複数のリクエストを並行処理する場合に発揮されます。

```python
import aiohttp
import asyncio
import time

async def fetch_url(session, url):
    async with session.get(url) as response:
        # レスポンスのテキストを取得
        return await response.text()

async def main():
    # 取得するURLのリスト
    urls = [
        "https://jsonplaceholder.typicode.com/posts/1",
        "https://jsonplaceholder.typicode.com/posts/2",
        "https://jsonplaceholder.typicode.com/posts/3",
        "https://jsonplaceholder.typicode.com/posts/4",
        "https://jsonplaceholder.typicode.com/posts/5"
    ]
    
    start_time = time.time()
    
    # 1つのセッションを共有して複数のリクエストを処理
    async with aiohttp.ClientSession() as session:
        # 全URLに対してfetch_urlタスクを作成
        tasks = [fetch_url(session, url) for url in urls]
        # 全タスクを並行実行し、結果を待機
        results = await asyncio.gather(*tasks)
        
        # 各結果の長さを表示
        for i, result in enumerate(results):
            print(f"URL {i+1} のレスポンス長: {len(result)} 文字")
    
    end_time = time.time()
    print(f"処理時間: {end_time - start_time:.2f} 秒")

# イベントループの実行
asyncio.run(main())
```

このコードを入力して実行してみましょう。以下のような出力が表示されるはずです：

```
URL 1 のレスポンス長: 292 文字
URL 2 のレスポンス長: 292 文字
URL 3 のレスポンス長: 292 文字
URL 4 のレスポンス長: 292 文字
URL 5 のレスポンス長: 292 文字
処理時間: 0.XX 秒
```

**解説**:
- `asyncio.gather()`を使用して複数のタスクを並行実行します
- 1つのセッションを共有することでTCPコネクションを再利用し、効率的に処理できます
- 従来の同期処理と比較して、処理時間が大幅に短縮されます

### 4. カスタムヘッダーとパラメータの設定

HTTPリクエストにヘッダーやパラメータを追加する方法を見てみましょう。

```python
import aiohttp
import asyncio

async def fetch_with_params(url):
    # カスタムヘッダーの設定
    headers = {
        "User-Agent": "MyPythonApp/1.0",
        "Accept": "application/json"
    }
    
    # クエリパラメータの設定
    params = {
        "userId": 1,
        "completed": "false"
    }
    
    async with aiohttp.ClientSession() as session:
        async with session.get(url, headers=headers, params=params) as response:
            print(f"リクエストURL: {response.url}")
            print(f"ステータスコード: {response.status}")
            data = await response.json()
            # 最初の2つの結果だけ表示
            return data[:2]

async def main():
    url = "https://jsonplaceholder.typicode.com/todos"
    results = await fetch_with_params(url)
    print("取得した結果:")
    for item in results:
        print(f"  - タイトル: {item['title']}")
        print(f"    完了状態: {item['completed']}")

asyncio.run(main())
```

このコードを入力して実行してみましょう。以下のような出力が表示されるはずです：

```
リクエストURL: https://jsonplaceholder.typicode.com/todos?userId=1&completed=false
ステータスコード: 200
取得した結果:
  - タイトル: delectus aut autem
    完了状態: False
  - タイトル: quis ut nam facilis et officia qui
    完了状態: False
```

**解説**:
- `headers`パラメータでHTTPヘッダーを設定できます
- `params`パラメータでクエリパラメータを設定できます
- 実際のリクエストURLには、指定したパラメータが追加されています

### 5. POSTリクエストの送信

データをサーバーに送信するPOSTリクエストの例を見てみましょう。

```python
import aiohttp
import asyncio

async def post_data(url, data):
    async with aiohttp.ClientSession() as session:
        # POSTリクエストの送信
        async with session.post(url, json=data) as response:
            print(f"ステータスコード: {response.status}")
            # レスポンスをJSONとして取得
            return await response.json()

async def main():
    url = "https://jsonplaceholder.typicode.com/posts"
    
    # 送信するデータ
    post_data = {
        "title": "aiohttpのテスト投稿",
        "body": "これはaiohttpを使ったPOSTリクエストのテストです",
        "userId": 1
    }
    
    result = await post_data(url, post_data)
    print("サーバーからの応答:")
    print(f"  - ID: {result['id']}")
    print(f"  - タイトル: {result['title']}")
    print(f"  - 本文: {result['body']}")

asyncio.run(main())
```

このコードを入力して実行してみましょう。以下のような出力が表示されるはずです：

```
ステータスコード: 201
サーバーからの応答:
  - ID: 101
  - タイトル: aiohttpのテスト投稿
  - 本文: これはaiohttpを使ったPOSTリクエストのテストです
```

**解説**:
- `session.post()`メソッドでPOSTリクエストを送信します
- `json`パラメータを使用すると、データを自動的にJSON形式に変換します
- ステータスコード201は、リソースが正常に作成されたことを示します

### 6. エラー処理

エラーが発生した場合の適切な処理方法を見てみましょう。

```python
import aiohttp
import asyncio

async def fetch_with_error_handling(url):
    try:
        async with aiohttp.ClientSession() as session:
            # タイムアウトを設定
            async with session.get(url, timeout=5) as response:
                # ステータスコードのチェック
                if response.status == 200:
                    return await response.json()
                else:
                    print(f"エラー: HTTPステータスコード {response.status}")
                    return None
    except aiohttp.ClientConnectorError:
        print(f"接続エラー: {url} に接続できませんでした")
        return None
    except asyncio.TimeoutError:
        print(f"タイムアウトエラー: {url} からの応答に時間がかかりすぎています")
        return None
    except Exception as e:
        print(f"予期せぬエラー: {str(e)}")
        return None

async def main():
    # 正常なURL
    good_url = "https://jsonplaceholder.typicode.com/todos/1"
    # 存在しないURL
    bad_url = "https://jsonplaceholder.typicode.com/non_existent"
    # 無効なドメイン
    invalid_url = "https://this-domain-does-not-exist-123456789.com"
    
    print("正常なURLのリクエスト:")
    good_result = await fetch_with_error_handling(good_url)
    if good_result:
        print(f"  成功: {good_result['title']}")
    
    print("\n存在しないURLのリクエスト:")
    await fetch_with_error_handling(bad_url)
    
    print("\n無効なドメインのリクエスト:")
    await fetch_with_error_handling(invalid_url)

asyncio.run(main())
```

このコードを入力して実行してみましょう。以下のような出力が表示されるはずです：

```
正常なURLのリクエスト:
  成功: delectus aut autem

存在しないURLのリクエスト:
エラー: HTTPステータスコード 404

無効なドメインのリクエスト:
接続エラー: https://this-domain-does-not-exist-123456789.com に接続できませんでした
```

**解説**:
- `try-except`ブロックでエラーを適切に処理します
- `aiohttp.ClientConnectorError`は接続エラーを捕捉します
- `asyncio.TimeoutError`はタイムアウトエラーを捕捉します
- ステータスコードのチェックも重要なエラー処理の一部です

### 7. シンプルなHTTPサーバーの作成

aiohttpを使用して簡単なHTTPサーバーを作成する例を見てみましょう。

```python
from aiohttp import web
import asyncio

# ルートハンドラ
async def handle_root(request):
    return web.Response(text="こんにちは、aiohttpサーバーへようこそ！")

# JSONレスポンスを返すハンドラ
async def handle_json(request):
    data = {
        "message": "これはJSONレスポンスです",
        "status": "success",
        "code": 200
    }
    return web.json_response(data)

# パラメータを受け取るハンドラ
async def handle_greeting(request):
    name = request.match_info.get('name', "ゲスト")
    return web.Response(text=f"こんにちは、{name}さん！")

# サーバーのセットアップ
def setup_server():
    app = web.Application()
    app.add_routes([
        web.get('/', handle_root),
        web.get('/json', handle_json),
        web.get('/hello/{name}', handle_greeting)
    ])
    return app

# サーバーの実行
if __name__ == '__main__':
    app = setup_server()
    print("サーバーを起動します。http://localhost:8080/ にアクセスしてください")
    web.run_app(app)
```

このコードを入力して実行してみましょう。ターミナルには以下のような出力が表示されます：

```
サーバーを起動します。http://localhost:8080/ にアクセスしてください
======== Running on http://0.0.0.0:8080 ========
(Press CTRL+C to quit)
```

ブラウザで以下のURLにアクセスして動作を確認できます：
- http://localhost:8080/ - 「こんにちは、aiohttpサーバーへようこそ！」と表示
- http://localhost:8080/json - JSONレスポンスを表示
- http://localhost:8080/hello/Python - 「こんにちは、Pythonさん！」と表示

**解説**:
- `web.Application()`でアプリケーションインスタンスを作成します
- `app.add_routes()`でルーティングを設定します
- ハンドラ関数は非同期関数として定義し、`request`オブジェクトを受け取ります
- `web.run_app()`でサーバーを起動します

## まとめ

aiohttpはPythonで非同期HTTP通信を行うための強力なライブラリです。クライアントとサーバーの両方の機能を提供し、asyncioを活用することで効率的なI/O処理を実現します。このチュートリアルで学んだ基本的な使い方を応用して、高性能なWebアプリケーションやAPIクライアントを開発できるようになりました。
