# Python ウェブフレームワーク Tornado 入門

## 概要
Tornadoは非同期I/Oに特化した高速なPythonウェブフレームワークで、高いスケーラビリティが特徴です。

## 主要概念
Tornadoは非同期処理とノンブロッキングI/Oを活用し、単一プロセスで多数の同時接続を効率的に処理できます。

## 環境構築

まずはTornadoをインストールしましょう。以下のコマンドをターミナルやコマンドプロンプトで実行してください。

```bash
pip install tornado
```

## 基本的なウェブサーバーの作成

以下のコードを`simple_server.py`という名前で保存してください。これは最も基本的なTornadoウェブサーバーの例です。

```python
import tornado.ioloop
import tornado.web

# リクエストハンドラーの定義
class MainHandler(tornado.web.RequestHandler):
    def get(self):
        # GETリクエストに対する処理
        self.write("こんにちは、Tornadoの世界へようこそ！")

# アプリケーションの設定
def make_app():
    return tornado.web.Application([
        # URLパターンとハンドラーのマッピング
        (r"/", MainHandler),
    ])

if __name__ == "__main__":
    # アプリケーションの作成
    app = make_app()
    # ポート8888でサーバーを起動
    app.listen(8888)
    print("サーバーを起動しました。http://localhost:8888 にアクセスしてください。")
    # イベントループの開始
    tornado.ioloop.IOLoop.current().start()
```

このコードを入力して実行してみましょう：

```bash
python simple_server.py
```

実行すると、「サーバーを起動しました。http://localhost:8888 にアクセスしてください。」というメッセージが表示され、サーバーが起動します。ブラウザで http://localhost:8888 にアクセスすると、「こんにちは、Tornadoの世界へようこそ！」というメッセージが表示されます。

## URLパラメータの処理

次に、URLからパラメータを取得する方法を学びましょう。`url_params.py`というファイルを作成し、以下のコードを入力してください。

```python
import tornado.ioloop
import tornado.web

class NameHandler(tornado.web.RequestHandler):
    def get(self, name):
        # URLから取得した名前を使用して挨拶
        self.write(f"こんにちは、{name}さん！")

class QueryParamHandler(tornado.web.RequestHandler):
    def get(self):
        # クエリパラメータを取得
        name = self.get_argument("name", "ゲスト")
        age = self.get_argument("age", "不明")
        self.write(f"名前: {name}, 年齢: {age}")

def make_app():
    return tornado.web.Application([
        # 正規表現でURLパターンを定義し、パラメータをキャプチャ
        (r"/hello/([^/]+)", NameHandler),
        (r"/query", QueryParamHandler),
    ])

if __name__ == "__main__":
    app = make_app()
    app.listen(8888)
    print("サーバーを起動しました。以下のURLにアクセスしてみてください：")
    print("- http://localhost:8888/hello/太郎")
    print("- http://localhost:8888/query?name=花子&age=25")
    tornado.ioloop.IOLoop.current().start()
```

このコードを入力して実行してみましょう：

```bash
python url_params.py
```

以下の2つのURLにアクセスして、結果を確認しましょう：
1. http://localhost:8888/hello/太郎 にアクセスすると「こんにちは、太郎さん！」と表示されます。
2. http://localhost:8888/query?name=花子&age=25 にアクセスすると「名前: 花子, 年齢: 25」と表示されます。

## テンプレートを使用したHTMLレンダリング

Tornadoには組み込みのテンプレートエンジンがあります。`templates`ディレクトリを作成し、その中に`index.html`を作成してください。

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{{ title }}</title>
    <style>
        body { font-family: sans-serif; margin: 20px; }
        .user-info { background-color: #f0f0f0; padding: 10px; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>{{ title }}</h1>
    <div class="user-info">
        <p>ようこそ、{{ username }}さん！</p>
        <p>現在の時刻: {{ current_time }}</p>
    </div>
    <h2>趣味リスト</h2>
    <ul>
        {% for hobby in hobbies %}
            <li>{{ hobby }}</li>
        {% end %}
    </ul>
</body>
</html>
```

次に、`template_example.py`ファイルを作成し、以下のコードを入力してください。

```python
import tornado.ioloop
import tornado.web
import datetime

class TemplateHandler(tornado.web.RequestHandler):
    def get(self):
        # テンプレートに渡すデータ
        template_data = {
            "title": "Tornadoテンプレート例",
            "username": "ユーザー",
            "current_time": datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            "hobbies": ["読書", "プログラミング", "料理", "旅行"]
        }
        # テンプレートをレンダリング
        self.render("templates/index.html", **template_data)

def make_app():
    return tornado.web.Application([
        (r"/", TemplateHandler),
    ])

if __name__ == "__main__":
    app = make_app()
    app.listen(8888)
    print("サーバーを起動しました。http://localhost:8888 にアクセスしてください。")
    tornado.ioloop.IOLoop.current().start()
```

このコードを入力して実行してみましょう：

```bash
python template_example.py
```

ブラウザで http://localhost:8888 にアクセスすると、テンプレートを使用したHTMLページが表示されます。タイトル、ユーザー名、現在時刻、趣味のリストがテンプレートに埋め込まれていることが確認できます。

## フォーム処理

フォームからデータを受け取る例を見てみましょう。まず、`templates`ディレクトリに`form.html`を作成してください。

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>フォーム処理の例</title>
    <style>
        body { font-family: sans-serif; margin: 20px; }
        form { background-color: #f0f0f0; padding: 15px; border-radius: 5px; }
        input, select { margin: 5px 0; padding: 5px; }
        button { padding: 8px 15px; background-color: #4CAF50; color: white; border: none; cursor: pointer; }
        .result { margin-top: 20px; padding: 10px; background-color: #e8f5e9; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>フォーム処理の例</h1>
    
    <form method="post">
        <div>
            <label for="name">名前:</label><br>
            <input type="text" id="name" name="name" required>
        </div>
        <div>
            <label for="email">メールアドレス:</label><br>
            <input type="email" id="email" name="email" required>
        </div>
        <div>
            <label for="age">年齢:</label><br>
            <input type="number" id="age" name="age" min="1" max="120">
        </div>
        <div>
            <label for="programmer_type">プログラマータイプ:</label><br>
            <select id="programmer_type" name="programmer_type">
                <option value="beginner">初心者</option>
                <option value="intermediate">中級者</option>
                <option value="advanced">上級者</option>
            </select>
        </div>
        <div>
            <button type="submit">送信</button>
        </div>
    </form>
    
    {% if submitted %}
    <div class="result">
        <h2>送信結果:</h2>
        <p><strong>名前:</strong> {{ name }}</p>
        <p><strong>メールアドレス:</strong> {{ email }}</p>
        <p><strong>年齢:</strong> {{ age }}</p>
        <p><strong>プログラマータイプ:</strong> {{ programmer_type_ja }}</p>
    </div>
    {% end %}
</body>
</html>
```

次に、`form_handling.py`ファイルを作成し、以下のコードを入力してください。

```python
import tornado.ioloop
import tornado.web

class FormHandler(tornado.web.RequestHandler):
    def get(self):
        # GETリクエスト時はフォームのみを表示
        self.render("templates/form.html", submitted=False)
    
    def post(self):
        # POSTリクエストからフォームデータを取得
        name = self.get_argument("name")
        email = self.get_argument("email")
        age = self.get_argument("age")
        programmer_type = self.get_argument("programmer_type")
        
        # プログラマータイプを日本語に変換
        programmer_type_ja = {
            "beginner": "初心者",
            "intermediate": "中級者",
            "advanced": "上級者"
        }.get(programmer_type, programmer_type)
        
        # 結果を含めてテンプレートをレンダリング
        self.render(
            "templates/form.html", 
            submitted=True,
            name=name,
            email=email,
            age=age,
            programmer_type_ja=programmer_type_ja
        )

def make_app():
    return tornado.web.Application([
        (r"/", FormHandler),
    ])

if __name__ == "__main__":
    app = make_app()
    app.listen(8888)
    print("サーバーを起動しました。http://localhost:8888 にアクセスしてください。")
    tornado.ioloop.IOLoop.current().start()
```

このコードを入力して実行してみましょう：

```bash
python form_handling.py
```

ブラウザで http://localhost:8888 にアクセスし、フォームに情報を入力して送信ボタンをクリックすると、入力した情報が画面に表示されます。

## JSONレスポンス（APIの作成）

Tornadoを使ってAPIを作成する方法を学びましょう。`json_api.py`ファイルを作成し、以下のコードを入力してください。

```python
import tornado.ioloop
import tornado.web
import json

# ダミーデータ（実際のアプリケーションではデータベースを使用）
users = [
    {"id": 1, "name": "田中太郎", "email": "tanaka@example.com", "age": 28},
    {"id": 2, "name": "佐藤花子", "email": "sato@example.com", "age": 24},
    {"id": 3, "name": "鈴木一郎", "email": "suzuki@example.com", "age": 32}
]

class UserListHandler(tornado.web.RequestHandler):
    def get(self):
        # JSONヘッダーを設定
        self.set_header("Content-Type", "application/json")
        # ユーザーリストをJSONで返す
        self.write(json.dumps(users, ensure_ascii=False))

class UserDetailHandler(tornado.web.RequestHandler):
    def get(self, user_id):
        user_id = int(user_id)
        # 指定されたIDのユーザーを検索
        user = next((u for u in users if u["id"] == user_id), None)
        
        if user:
            # ユーザーが見つかった場合
            self.set_header("Content-Type", "application/json")
            self.write(json.dumps(user, ensure_ascii=False))
        else:
            # ユーザーが見つからない場合は404エラー
            self.set_status(404)
            self.write(json.dumps({"error": "ユーザーが見つかりません"}, ensure_ascii=False))

class CreateUserHandler(tornado.web.RequestHandler):
    def post(self):
        # リクエストボディからJSONデータを取得
        try:
            data = json.loads(self.request.body)
        except json.JSONDecodeError:
            self.set_status(400)
            self.write(json.dumps({"error": "無効なJSONデータです"}, ensure_ascii=False))
            return
        
        # 必須フィールドのチェック
        if not all(key in data for key in ["name", "email", "age"]):
            self.set_status(400)
            self.write(json.dumps({"error": "name, email, ageは必須です"}, ensure_ascii=False))
            return
        
        # 新しいユーザーIDを生成
        new_id = max(user["id"] for user in users) + 1
        
        # 新しいユーザーを作成
        new_user = {
            "id": new_id,
            "name": data["name"],
            "email": data["email"],
            "age": data["age"]
        }
        
        # ユーザーリストに追加
        users.append(new_user)
        
        # 作成したユーザー情報を返す
        self.set_status(201)  # Created
        self.set_header("Content-Type", "application/json")
        self.write(json.dumps(new_user, ensure_ascii=False))

def make_app():
    return tornado.web.Application([
        (r"/api/users", UserListHandler),
        (r"/api/users/([0-9]+)", UserDetailHandler),
        (r"/api/users/create", CreateUserHandler),
    ])

if __name__ == "__main__":
    app = make_app()
    app.listen(8888)
    print("JSONのAPIサーバーを起動しました。以下のエンドポイントが利用可能です：")
    print("- GET http://localhost:8888/api/users (ユーザー一覧)")
    print("- GET http://localhost:8888/api/users/1 (ID=1のユーザー詳細)")
    print("- POST http://localhost:8888/api/users/create (新規ユーザー作成)")
    tornado.ioloop.IOLoop.current().start()
```

このコードを入力して実行してみましょう：

```bash
python json_api.py
```

APIをテストするには、以下の方法があります：

1. ブラウザで http://localhost:8888/api/users にアクセスすると、すべてのユーザー情報がJSON形式で表示されます。
2. ブラウザで http://localhost:8888/api/users/1 にアクセスすると、ID=1のユーザー情報が表示されます。
3. POSTリクエストのテストには、curlコマンドやPostmanなどのツールを使用できます。

例えば、curlを使用して新しいユーザーを作成する場合：

```bash
curl -X POST -H "Content-Type: application/json" -d '{"name":"山田次郎","email":"yamada@example.com","age":30}' http://localhost:8888/api/users/create
```

## 非同期処理

Tornadoの最大の特徴である非同期処理の例を見てみましょう。`async_example.py`ファイルを作成し、以下のコードを入力してください。

```python
import tornado.ioloop
import tornado.web
import tornado.gen
import time
import asyncio

class SyncHandler(tornado.web.RequestHandler):
    def get(self):
        # 同期的な処理（ブロッキング）
        start_time = time.time()
        
        # 3秒間スリープ（重い処理のシミュレーション）
        time.sleep(3)
        
        end_time = time.time()
        processing_time = end_time - start_time
        
        self.write(f"同期処理が完了しました。処理時間: {processing_time:.2f}秒")

class AsyncHandler(tornado.web.RequestHandler):
    async def get(self):
        # 非同期処理（ノンブロッキング）
        start_time = time.time()
        
        # 非同期的に3秒間待機
        await asyncio.sleep(3)
        
        end_time = time.time()
        processing_time = end_time - start_time
        
        self.write(f"非同期処理が完了しました。処理時間: {processing_time:.2f}秒")

class MultiTaskHandler(tornado.web.RequestHandler):
    async def get(self):
        start_time = time.time()
        
        # 複数の非同期タスクを同時に実行
        results = await asyncio.gather(
            self.task("タスク1", 2),
            self.task("タスク2", 1),
            self.task("タスク3", 3)
        )
        
        end_time = time.time()
        total_time = end_time - start_time
        
        # 結果を表示
        response = f"すべてのタスクが完了しました。合計処理時間: {total_time:.2f}秒<br>"
        for result in results:
            response += f"- {result}<br>"
            
        self.write(response)
    
    async def task(self, name, seconds):
        # 非同期タスクの例
        await asyncio.sleep(seconds)
        return f"{name}: {seconds}秒の処理が完了"

def make_app():
    return tornado.web.Application([
        (r"/sync", SyncHandler),
        (r"/async", AsyncHandler),
        (r"/multi", MultiTaskHandler),
    ])

if __name__ == "__main__":
    app = make_app()
    app.listen(8888)
    print("非同期処理のサンプルサーバーを起動しました。以下のURLにアクセスしてみてください：")
    print("- http://localhost:8888/sync (同期処理)")
    print("- http://localhost:8888/async (非同期処理)")
    print("- http://localhost:8888/multi (複数の非同期タスク)")
    tornado.ioloop.IOLoop.current().start()
```

このコードを入力して実行してみましょう：

```bash
python async_example.py
```

以下のURLにアクセスして、同期処理と非同期処理の違いを体験してください：

1. http://localhost:8888/sync にアクセスすると、サーバーは同期的に3秒間待機し、その間他のリクエストは処理されません。
2. http://localhost:8888/async にアクセスすると、サーバーは非同期的に3秒間待機し、その間も他のリクエストを処理できます。
3. http://localhost:8888/multi にアクセスすると、3つの非同期タスクを同時に実行します。最も時間のかかるタスク（3秒）に合わせて約3秒で処理が完了します。

複数のブラウザタブで同時にアクセスし、同期処理と非同期処理の違いを確認してみてください。同期処理の場合は一つのリクエストが完了するまで他のリクエストが処理されませんが、非同期処理の場合は複数のリクエストを同時に処理できます。

## まとめ

この講義では、Tornado Webフレームワークの基本的な使い方を学びました：

1. 基本的なウェブサーバーの作成
2. URLパラメータの処理
3. テンプレートを使用したHTMLレンダリング
4. フォーム処理
5. JSONレスポンス（API）の作成
6. 非同期処理

Tornadoの最大の特徴は非同期I/Oを活用した高いパフォーマンスです。リアルタイム通信やAPIサーバーなど、多数の同時接続を効率的に処理する必要があるアプリケーションに特に適しています。
