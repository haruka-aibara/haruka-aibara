# Pyramidウェブフレームワーク入門

## はじめに
Pyramidは柔軟性が高く、スケーラブルなPythonウェブフレームワークで、小規模から大規模なウェブアプリケーション開発まで対応できます。

## 基本概念
Pyramidは「設定より規約」と「規約より設定」の両方のアプローチをサポートし、ルーティング、ビュー、テンプレート、セキュリティなどの機能を直感的に扱えます。

## ステップバイステップ実装ガイド

### 1. Pyramidのインストール

まずは、Pyramidをインストールしましょう。以下のコマンドをターミナルで実行してください。

```bash
pip install pyramid
```

### 2. 最小限のPyramidアプリケーション

以下の最小限のPyramidアプリケーションを作成してみましょう。新しいファイル`hello.py`を作成し、次のコードを入力してください。

```python
from wsgiref.simple_server import make_server
from pyramid.config import Configurator
from pyramid.response import Response

# ビュー関数の定義
def hello_world(request):
    # シンプルなレスポンスを返す
    return Response('こんにちは、Pyramidの世界へようこそ！')

if __name__ == '__main__':
    # Pyramidの設定オブジェクトを作成
    with Configurator() as config:
        # ルートURLへのルーティングを設定
        config.add_route('hello', '/')
        # ルートに対応するビュー関数を設定
        config.add_view(hello_world, route_name='hello')
        # WSGIアプリケーションの作成
        app = config.make_wsgi_app()
    
    # サーバーの作成と起動
    server = make_server('0.0.0.0', 6543, app)
    print('サーバーが http://localhost:6543 で起動しました')
    server.serve_forever()
```

**このコードを入力して実行してみましょう：**

```bash
python hello.py
```

**実行結果：**
ターミナルに「サーバーが http://localhost:6543 で起動しました」と表示され、ウェブブラウザで http://localhost:6543 にアクセスすると「こんにちは、Pyramidの世界へようこそ！」というメッセージが表示されます。

このシンプルな例では、Pyramidの最も基本的な機能を使っています。`Configurator`オブジェクトを使ってルートとビュー関数の関連付けを行い、WSGIアプリケーションを作成しています。

### 3. テンプレートを使ったアプリケーション

次は、テンプレートを使ったもう少し複雑な例を作成しましょう。まず、必要なパッケージをインストールします。

```bash
pip install pyramid jinja2
```

次に、以下のディレクトリ構造を作成します：

```
pyramid_app/
├── app.py
└── templates/
    └── home.jinja2
```

`templates/home.jinja2`ファイルを作成し、以下の内容を入力してください：

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Pyramid アプリケーション</title>
    <style>
        body {
            font-family: sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        .message {
            background-color: #f0f0f0;
            border-left: 5px solid #007bff;
            padding: 10px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <h1>{{ project_name }}</h1>
    <div class="message">
        <p>{{ message }}</p>
    </div>
    <p>今日の日付: {{ current_date }}</p>
    <h2>タスクリスト</h2>
    <ul>
        {% for task in tasks %}
        <li>{{ task }}</li>
        {% endfor %}
    </ul>
</body>
</html>
```

次に、`app.py`ファイルを作成し、以下のコードを入力してください：

```python
from wsgiref.simple_server import make_server
from pyramid.config import Configurator
from pyramid.renderers import render_to_response
from datetime import datetime
import os

# ビュー関数の定義
def home_view(request):
    # テンプレートに渡すデータを準備
    data = {
        'project_name': 'Pyramidチュートリアルアプリ',
        'message': 'Pyramidを使ったウェブアプリケーション開発を始めましょう！',
        'current_date': datetime.now().strftime('%Y年%m月%d日'),
        'tasks': [
            'Pyramidの基本を学ぶ',
            'ルーティングの仕組みを理解する',
            'テンプレートの使い方を習得する',
            'データベース連携を試す',
            'ウェブアプリをデプロイする'
        ]
    }
    
    # テンプレートをレンダリングしてレスポンスを返す
    return render_to_response('templates/home.jinja2', data, request=request)

if __name__ == '__main__':
    # カレントディレクトリを設定
    here = os.path.dirname(os.path.abspath(__file__))
    
    # Pyramidの設定
    with Configurator() as config:
        # Jinja2テンプレートの設定
        config.include('pyramid_jinja2')
        config.add_jinja2_renderer('.jinja2')
        
        # 静的アセットのパスを設定
        config.add_static_view(name='static', path=os.path.join(here, 'static'))
        
        # ルートへのルーティングを設定
        config.add_route('home', '/')
        config.add_view(home_view, route_name='home')
        
        # WSGIアプリケーションの作成
        app = config.make_wsgi_app()
    
    # サーバーの作成と起動
    server = make_server('0.0.0.0', 6543, app)
    print('サーバーが http://localhost:6543 で起動しました')
    server.serve_forever()
```

**このコードを入力して実行してみましょう：**

```bash
python app.py
```

**実行結果：**
ターミナルに「サーバーが http://localhost:6543 で起動しました」と表示され、ウェブブラウザで http://localhost:6543 にアクセスすると、スタイル適用されたHTMLページが表示されます。ページには「Pyramidチュートリアルアプリ」というタイトル、メッセージ、現在の日付、そしてタスクのリストが表示されます。

この例では、Jinja2テンプレートエンジンを使って動的なHTMLページを生成しています。`render_to_response`関数を使ってテンプレートをレンダリングし、データを渡しています。

### 4. フォーム処理を含むアプリケーション

次は、フォーム処理を含む簡単なアプリケーションを作成しましょう。

以下のディレクトリ構造を作成します：

```
pyramid_form_app/
├── app.py
└── templates/
    ├── form.jinja2
    └── result.jinja2
```

まず、`templates/form.jinja2`を作成します：

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Pyramid フォーム</title>
    <style>
        body {
            font-family: sans-serif;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
        }
        form {
            background-color: #f9f9f9;
            padding: 20px;
            border-radius: 5px;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        input, select, textarea {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        button {
            background-color: #007bff;
            color: white;
            border: none;
            padding: 10px 15px;
            border-radius: 4px;
            cursor: pointer;
        }
        button:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
    <h1>ユーザー登録フォーム</h1>
    <form action="/register" method="POST">
        <div class="form-group">
            <label for="username">ユーザー名:</label>
            <input type="text" id="username" name="username" required>
        </div>
        <div class="form-group">
            <label for="email">メールアドレス:</label>
            <input type="email" id="email" name="email" required>
        </div>
        <div class="form-group">
            <label for="age">年齢:</label>
            <input type="number" id="age" name="age" min="1" max="120">
        </div>
        <div class="form-group">
            <label for="prefecture">都道府県:</label>
            <select id="prefecture" name="prefecture">
                <option value="">選択してください</option>
                <option value="北海道">北海道</option>
                <option value="東京都">東京都</option>
                <option value="大阪府">大阪府</option>
                <option value="福岡県">福岡県</option>
                <option value="その他">その他</option>
            </select>
        </div>
        <div class="form-group">
            <label for="comment">コメント:</label>
            <textarea id="comment" name="comment" rows="4"></textarea>
        </div>
        <button type="submit">送信</button>
    </form>
</body>
</html>
```

次に、`templates/result.jinja2`を作成します：

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>登録完了</title>
    <style>
        body {
            font-family: sans-serif;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
        }
        .result {
            background-color: #e8f5e9;
            padding: 20px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            padding: 10px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #f5f5f5;
        }
        a {
            display: inline-block;
            margin-top: 20px;
            background-color: #007bff;
            color: white;
            padding: 10px 15px;
            text-decoration: none;
            border-radius: 4px;
        }
        a:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
    <h1>登録完了</h1>
    <div class="result">
        <p>{{ username }}さん、登録ありがとうございます！</p>
    </div>
    
    <h2>入力内容の確認</h2>
    <table>
        <tr>
            <th>項目</th>
            <th>入力内容</th>
        </tr>
        <tr>
            <td>ユーザー名</td>
            <td>{{ username }}</td>
        </tr>
        <tr>
            <td>メールアドレス</td>
            <td>{{ email }}</td>
        </tr>
        <tr>
            <td>年齢</td>
            <td>{{ age }}歳</td>
        </tr>
        <tr>
            <td>都道府県</td>
            <td>{{ prefecture }}</td>
        </tr>
        <tr>
            <td>コメント</td>
            <td>{{ comment }}</td>
        </tr>
    </table>
    
    <a href="/">フォームに戻る</a>
</body>
</html>
```

最後に、`app.py`を作成します：

```python
from wsgiref.simple_server import make_server
from pyramid.config import Configurator
from pyramid.renderers import render_to_response
from pyramid.view import view_config
from pyramid.httpexceptions import HTTPFound
import os

# フォーム表示用のビュー関数
def form_view(request):
    return render_to_response('templates/form.jinja2', {}, request=request)

# フォーム送信処理用のビュー関数
def register_view(request):
    # POSTデータの取得
    username = request.POST.get('username', '')
    email = request.POST.get('email', '')
    age = request.POST.get('age', '')
    prefecture = request.POST.get('prefecture', '')
    comment = request.POST.get('comment', '')
    
    # データを辞書にまとめる
    data = {
        'username': username,
        'email': email,
        'age': age,
        'prefecture': prefecture,
        'comment': comment
    }
    
    # 結果ページへレンダリング
    return render_to_response('templates/result.jinja2', data, request=request)

if __name__ == '__main__':
    # カレントディレクトリを設定
    here = os.path.dirname(os.path.abspath(__file__))
    
    # Pyramidの設定
    with Configurator() as config:
        # Jinja2テンプレートの設定
        config.include('pyramid_jinja2')
        config.add_jinja2_renderer('.jinja2')
        
        # ルーティングの設定
        config.add_route('home', '/')
        config.add_view(form_view, route_name='home')
        
        config.add_route('register', '/register')
        config.add_view(register_view, route_name='register', request_method='POST')
        
        # WSGIアプリケーションの作成
        app = config.make_wsgi_app()
    
    # サーバーの作成と起動
    server = make_server('0.0.0.0', 6543, app)
    print('サーバーが http://localhost:6543 で起動しました')
    server.serve_forever()
```

**このコードを入力して実行してみましょう：**

```bash
python app.py
```

**実行結果：**
ブラウザで http://localhost:6543 にアクセスすると、ユーザー登録フォームが表示されます。フォームに情報を入力して送信すると、`/register`にPOSTリクエストが送信され、入力データを表示した結果ページが表示されます。

この例では、フォームの表示と送信処理を別々のビュー関数で処理しています。`request.POST`を使用してフォームのデータを取得し、テンプレートにデータを渡して結果ページを表示しています。

### 5. データベース連携（SQLAlchemy）

最後に、SQLAlchemyを使ったデータベース連携の例を作成しましょう。まず、必要なパッケージをインストールします。

```bash
pip install pyramid sqlalchemy pyramid_tm zope.sqlalchemy
```

以下のディレクトリ構造を作成します：

```
pyramid_db_app/
├── app.py
├── models.py
└── templates/
    ├── list.jinja2
    └── add.jinja2
```

まず、`models.py`でデータベースモデルを定義します：

```python
from sqlalchemy import Column, Integer, Text, create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import scoped_session, sessionmaker
from zope.sqlalchemy import register

# データベースセッションの設定
engine = create_engine('sqlite:///tasks.sqlite')
session_factory = sessionmaker(bind=engine)
DBSession = scoped_session(session_factory)
register(DBSession)
Base = declarative_base()

# タスクモデルの定義
class Task(Base):
    __tablename__ = 'tasks'
    
    id = Column(Integer, primary_key=True)
    title = Column(Text, nullable=False)
    description = Column(Text)
    
    def __init__(self, title, description=''):
        self.title = title
        self.description = description

# データベーステーブルの作成
def initialize_db():
    Base.metadata.create_all(engine)
```

次に、`templates/list.jinja2`を作成します：

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>タスク管理</title>
    <style>
        body {
            font-family: sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        .task {
            background-color: #f9f9f9;
            padding: 15px;
            margin-bottom: 10px;
            border-radius: 5px;
            border-left: 4px solid #007bff;
        }
        .task-title {
            font-weight: bold;
            font-size: 1.2em;
            margin-bottom: 5px;
        }
        .task-description {
            color: #555;
        }
        .btn {
            display: inline-block;
            padding: 10px 15px;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            margin-top: 20px;
        }
        .btn:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
    <h1>タスク一覧</h1>
    
    {% if tasks %}
        {% for task in tasks %}
            <div class="task">
                <div class="task-title">{{ task.title }}</div>
                <div class="task-description">{{ task.description }}</div>
            </div>
        {% endfor %}
    {% else %}
        <p>登録されているタスクはありません。</p>
    {% endif %}
    
    <a href="/add" class="btn">新しいタスクを追加</a>
</body>
</html>
```

次に、`templates/add.jinja2`を作成します：

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>タスク追加</title>
    <style>
        body {
            font-family: sans-serif;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
        }
        form {
            background-color: #f9f9f9;
            padding: 20px;
            border-radius: 5px;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        input, textarea {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        textarea {
            height: 100px;
        }
        button {
            background-color: #007bff;
            color: white;
            border: none;
            padding: 10px 15px;
            border-radius: 4px;
            cursor: pointer;
        }
        button:hover {
            background-color: #0056b3;
        }
        .back-link {
            display: inline-block;
            margin-top: 20px;
            color: #007bff;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <h1>新しいタスクを追加</h1>
    
    <form action="/add" method="POST">
        <div class="form-group">
            <label for="title">タイトル:</label>
            <input type="text" id="title" name="title" required>
        </div>
        <div class="form-group">
            <label for="description">説明:</label>
            <textarea id="description" name="description"></textarea>
        </div>
        <button type="submit">追加</button>
    </form>
    
    <a href="/" class="back-link">タスク一覧に戻る</a>
</body>
</html>
```

最後に、`app.py`を作成します：

```python
from wsgiref.simple_server import make_server
from pyramid.config import Configurator
from pyramid.renderers import render_to_response
from pyramid.httpexceptions import HTTPFound
import os

# モデルのインポート
from models import DBSession, Task, initialize_db

# タスク一覧表示用のビュー関数
def list_tasks(request):
    # すべてのタスクをデータベースから取得
    tasks = DBSession.query(Task).all()
    return render_to_response('templates/list.jinja2', {'tasks': tasks}, request=request)

# タスク追加フォーム表示用のビュー関数
def add_task_form(request):
    return render_to_response('templates/add.jinja2', {}, request=request)

# タスク追加処理用のビュー関数
def add_task(request):
    # POSTデータの取得
    title = request.POST.get('title', '')
    description = request.POST.get('description', '')
    
    # 新しいタスクをデータベースに追加
    task = Task(title=title, description=description)
    DBSession.add(task)
    DBSession.flush()
    
    # タスク一覧ページにリダイレクト
    return HTTPFound(location=request.route_url('list'))

if __name__ == '__main__':
    # データベースの初期化
    initialize_db()
    
    # カレントディレクトリを設定
    here = os.path.dirname(os.path.abspath(__file__))
    
    # Pyramidの設定
    with Configurator() as config:
        # Jinja2テンプレートの設定
        config.include('pyramid_jinja2')
        config.add_jinja2_renderer('.jinja2')
        
        # トランザクション管理の設定
        config.include('pyramid_tm')
        
        # ルーティングの設定
        config.add_route('list', '/')
        config.add_view(list_tasks, route_name='list')
        
        config.add_route('add', '/add')
        config.add_view(add_task_form, route_name='add', request_method='GET')
        config.add_view(add_task, route_name='add', request_method='POST')
        
        # WSGIアプリケーションの作成
        app = config.make_wsgi_app()
    
    # サーバーの作成と起動
    server = make_server('0.0.0.0', 6543, app)
    print('サーバーが http://localhost:6543 で起動しました')
    server.serve_forever()
```

**このコードを入力して実行してみましょう：**

```bash
python app.py
```

**実行結果：**
ブラウザで http://localhost:6543 にアクセスすると、初期状態では空のタスク一覧が表示されます。「新しいタスクを追加」ボタンをクリックして `/add` にアクセスし、タスク追加フォームを表示します。タスクのタイトルと説明を入力して追加すると、データベースに保存され、更新されたタスク一覧ページにリダイレクトされます。

この例では、SQLAlchemyを使ってSQLiteデータベースとの連携を実装しています。`pyramid_tm`を使ってトランザクション管理を行い、`zope.sqlalchemy`を使ってセッション管理を行っています。これにより、データベース操作が自動的にコミットされるようになります。

## まとめ

以上がPyramidウェブフレームワークの基本的な使い方です。Pyramidは柔軟性が高く、小規模なアプリケーションから大規模なエンタープライズアプリケーションまで対応できる強力なフレームワークです。この入門ガイドでは、以下の内容をカバーしました：

1. 最小限のPyramidアプリケーション
2. テンプレートを使ったアプリケーション
3. フォーム処理を含むアプリケーション
4. データベース連携（SQLAlchemy）

これらの例をベースに、さらに機能を追加してPyramidの理解を深めていきましょう。
