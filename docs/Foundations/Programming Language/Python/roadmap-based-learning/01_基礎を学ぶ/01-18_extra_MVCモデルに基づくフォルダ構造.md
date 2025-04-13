# PythonでのMVCモデルに基づくフォルダ構造

## 概要
MVCモデルは、アプリケーションを「Model（データ処理）」「View（表示）」「Controller（制御）」の3つの役割に分離する設計パターンで、コードの保守性と再利用性を高めます。

## 主要概念
MVCモデルでは、Modelがデータとビジネスロジックを担当し、Viewが表示を、Controllerがユーザー入力の処理とModelとViewの連携を担当します。

## 実践: シンプルなMVCパターンの実装

それでは、シンプルなTodo管理アプリケーションを例に、MVCパターンを実装していきましょう。

### ステップ1: フォルダ構造を作成する

まずは、以下のようなフォルダ構造を作成します。

```
todo_app/
│
├── models/
│   ├── __init__.py
│   └── todo_model.py
│
├── views/
│   ├── __init__.py
│   └── todo_view.py
│
├── controllers/
│   ├── __init__.py
│   └── todo_controller.py
│
└── app.py
```

このフォルダ構造を作成してみましょう。以下のコマンドを実行します：

```bash
mkdir -p todo_app/models todo_app/views todo_app/controllers
touch todo_app/models/__init__.py todo_app/models/todo_model.py
touch todo_app/views/__init__.py todo_app/views/todo_view.py
touch todo_app/controllers/__init__.py todo_app/controllers/todo_controller.py
touch todo_app/app.py
```

### ステップ2: Modelの実装

Model部分を実装しましょう。`todo_model.py`に以下のコードを入力します：

```python
class TodoModel:
    def __init__(self):
        # Todoリストを保持する辞書
        self.todos = {}
        self.next_id = 1
    
    def add_todo(self, title, description):
        """Todoを追加するメソッド"""
        todo_id = self.next_id
        self.todos[todo_id] = {
            'id': todo_id,
            'title': title,
            'description': description,
            'completed': False
        }
        self.next_id += 1
        return todo_id
    
    def get_todo(self, todo_id):
        """指定IDのTodoを取得するメソッド"""
        return self.todos.get(todo_id)
    
    def get_all_todos(self):
        """すべてのTodoを取得するメソッド"""
        return list(self.todos.values())
    
    def update_todo(self, todo_id, title=None, description=None, completed=None):
        """Todoを更新するメソッド"""
        if todo_id in self.todos:
            if title is not None:
                self.todos[todo_id]['title'] = title
            if description is not None:
                self.todos[todo_id]['description'] = description
            if completed is not None:
                self.todos[todo_id]['completed'] = completed
            return True
        return False
    
    def delete_todo(self, todo_id):
        """Todoを削除するメソッド"""
        if todo_id in self.todos:
            del self.todos[todo_id]
            return True
        return False
```

このコードを入力して実行してみましょう。このModelクラスは、Todoアイテムの追加、取得、更新、削除の基本的なCRUD操作を提供します。

### ステップ3: Viewの実装

次に、View部分を実装します。`todo_view.py`に以下のコードを入力します：

```python
class TodoView:
    def display_todo(self, todo):
        """1つのTodoを表示するメソッド"""
        if todo:
            status = "完了" if todo['completed'] else "未完了"
            print(f"ID: {todo['id']}")
            print(f"タイトル: {todo['title']}")
            print(f"説明: {todo['description']}")
            print(f"状態: {status}")
            print("-" * 30)
        else:
            print("指定されたTodoは存在しません。")
    
    def display_all_todos(self, todos):
        """すべてのTodoを表示するメソッド"""
        if todos:
            print("===== Todoリスト =====")
            for todo in todos:
                self.display_todo(todo)
        else:
            print("Todoはまだ登録されていません。")
    
    def get_todo_input(self):
        """ユーザーからTodoの情報を取得するメソッド"""
        print("\n新しいTodoを追加します")
        title = input("タイトル: ")
        description = input("説明: ")
        return title, description
    
    def get_todo_id(self):
        """ユーザーからTodo IDを取得するメソッド"""
        try:
            todo_id = int(input("Todo ID: "))
            return todo_id
        except ValueError:
            print("有効な数値を入力してください。")
            return None
    
    def display_menu(self):
        """メニューを表示するメソッド"""
        print("\n===== Todoアプリ =====")
        print("1. すべてのTodoを表示")
        print("2. 新しいTodoを追加")
        print("3. Todoを更新")
        print("4. Todoを削除")
        print("5. 終了")
        
        try:
            choice = int(input("選択してください (1-5): "))
            return choice
        except ValueError:
            print("有効な数値を入力してください。")
            return 0
    
    def get_update_info(self):
        """更新情報を取得するメソッド"""
        print("\nTodoを更新します（変更しない項目は空欄のままEnterを押してください）")
        title = input("新しいタイトル: ")
        description = input("新しい説明: ")
        
        completed_input = input("完了状態 (完了: 1, 未完了: 0): ")
        completed = None
        if completed_input in ['0', '1']:
            completed = (completed_input == '1')
        
        return title or None, description or None, completed
    
    def display_message(self, message):
        """メッセージを表示するメソッド"""
        print(message)
```

このViewクラスは、コンソールベースのユーザーインターフェースを提供します。Todoの表示や入力フォームの提供などを担当します。

### ステップ4: Controllerの実装

次に、Controller部分を実装します。`todo_controller.py`に以下のコードを入力します：

```python
class TodoController:
    def __init__(self, model, view):
        # ModelとViewの参照を保持
        self.model = model
        self.view = view
    
    def show_all_todos(self):
        """すべてのTodoを表示する"""
        todos = self.model.get_all_todos()
        self.view.display_all_todos(todos)
    
    def add_todo(self):
        """新しいTodoを追加する"""
        title, description = self.view.get_todo_input()
        todo_id = self.model.add_todo(title, description)
        self.view.display_message(f"ID: {todo_id} のTodoが追加されました。")
    
    def update_todo(self):
        """Todoを更新する"""
        todo_id = self.view.get_todo_id()
        if todo_id is not None:
            todo = self.model.get_todo(todo_id)
            if todo:
                self.view.display_todo(todo)
                title, description, completed = self.view.get_update_info()
                if self.model.update_todo(todo_id, title, description, completed):
                    self.view.display_message("Todoが更新されました。")
                else:
                    self.view.display_message("更新に失敗しました。")
            else:
                self.view.display_message(f"ID: {todo_id} のTodoは存在しません。")
    
    def delete_todo(self):
        """Todoを削除する"""
        todo_id = self.view.get_todo_id()
        if todo_id is not None:
            if self.model.delete_todo(todo_id):
                self.view.display_message(f"ID: {todo_id} のTodoが削除されました。")
            else:
                self.view.display_message(f"ID: {todo_id} のTodoは存在しません。")
    
    def run(self):
        """アプリケーションを実行する"""
        running = True
        while running:
            choice = self.view.display_menu()
            
            if choice == 1:
                self.show_all_todos()
            elif choice == 2:
                self.add_todo()
            elif choice == 3:
                self.update_todo()
            elif choice == 4:
                self.delete_todo()
            elif choice == 5:
                self.view.display_message("アプリケーションを終了します。")
                running = False
            else:
                self.view.display_message("無効な選択です。1から5の数字を入力してください。")
```

このControllerクラスは、ModelとViewの間の橋渡し役を果たします。ユーザーの入力に基づいて適切なModelの操作を実行し、結果をViewで表示します。

### ステップ5: メインアプリケーションの実装

最後に、アプリケーションを実行するためのメインファイルを実装します。`app.py`に以下のコードを入力します：

```python
from models.todo_model import TodoModel
from views.todo_view import TodoView
from controllers.todo_controller import TodoController

def main():
    # ModelとViewのインスタンスを作成
    model = TodoModel()
    view = TodoView()
    
    # Controllerを作成し、ModelとViewを渡す
    controller = TodoController(model, view)
    
    # アプリケーションを実行
    controller.run()

if __name__ == "__main__":
    main()
```

このコードを入力して実行してみましょう。以下のコマンドでアプリケーションを実行します：

```bash
cd todo_app
python app.py
```

実行すると、コンソールにメニューが表示され、Todoアプリケーションを操作できるようになります。

## 実行結果の解説

アプリケーションを実行すると、以下のようなメニューが表示されます：

```
===== Todoアプリ =====
1. すべてのTodoを表示
2. 新しいTodoを追加
3. Todoを更新
4. Todoを削除
5. 終了
選択してください (1-5): 
```

1. 「2」を選択して新しいTodoを追加してみましょう：

```
新しいTodoを追加します
タイトル: 買い物に行く
説明: 牛乳とパンを買う
ID: 1 のTodoが追加されました。
```

2. 「1」を選択してすべてのTodoを表示してみましょう：

```
===== Todoリスト =====
ID: 1
タイトル: 買い物に行く
説明: 牛乳とパンを買う
状態: 未完了
------------------------------
```

3. 「3」を選択してTodoを更新してみましょう：

```
Todo ID: 1
ID: 1
タイトル: 買い物に行く
説明: 牛乳とパンを買う
状態: 未完了
------------------------------

Todoを更新します（変更しない項目は空欄のままEnterを押してください）
新しいタイトル: 
新しい説明: 牛乳、パン、卵を買う
完了状態 (完了: 1, 未完了: 0): 1
Todoが更新されました。
```

4. 再度「1」を選択して更新されたTodoを確認しましょう：

```
===== Todoリスト =====
ID: 1
タイトル: 買い物に行く
説明: 牛乳、パン、卵を買う
状態: 完了
------------------------------
```

5. 「4」を選択してTodoを削除してみましょう：

```
Todo ID: 1
ID: 1 のTodoが削除されました。
```

6. 「5」を選択してアプリケーションを終了します。

## まとめ

MVCモデルを用いると、アプリケーションのコードを役割ごとに明確に分離できます：

- **Model**: データとビジネスロジックを担当（`TodoModel`クラス）
- **View**: ユーザーインターフェースと表示を担当（`TodoView`クラス）
- **Controller**: ModelとViewの連携およびユーザー入力の処理を担当（`TodoController`クラス）

この構造により、コードの保守性が向上し、将来的な機能追加や変更も容易になります。例えば、コンソールベースのViewをグラフィカルなインターフェース（GUIやWebインターフェース）に変更する場合でも、ModelとControllerの大部分は再利用できます。
