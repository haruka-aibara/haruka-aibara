# Pyright 入門

## 概要と重要性
Pyrightは、Microsoftが開発した静的型チェックツールで、Pythonコードの品質向上と早期のバグ発見に役立ちます。

## 主要概念
Pyrightは型ヒントを使用してコードを分析し、実行前に型関連のエラーを検出することができます。

## 実践ガイド

### 1. インストール方法

まず、Pyrightをインストールしてみましょう。以下のコマンドを入力して実行してください。

```python
# pipを使ってPyrightをインストール
pip install pyright
```

実行結果：
```
Collecting pyright
  Downloading pyright-1.1.350-py3-none-any.whl (780 kB)
     |████████████████████████████████| 780 kB 2.3 MB/s
Requirement already satisfied: nodeenv>=1.6.0 in /usr/local/lib/python3.9/site-packages (from pyright) (1.7.0)
Installing collected packages: pyright
Successfully installed pyright-1.1.350
```

### 2. 基本的な型チェック

以下のコードを`type_check_example.py`というファイル名で保存してみましょう。

```python
# 整数型の変数を定義
age: int = 25

# 文字列型の変数を定義
name: str = "田中太郎"

# リスト型（整数のリスト）の変数を定義
scores: list[int] = [80, 75, 90]

# 辞書型の変数を定義
person: dict[str, str] = {"name": "佐藤花子", "occupation": "エンジニア"}

# 関数に型アノテーションを追加
def greet(name: str) -> str:
    return f"こんにちは、{name}さん！"

# 関数を呼び出し
message = greet(name)
print(message)

# 型エラーになる例（コメントアウトを外すとエラーになります）
# wrong_message = greet(age)  # 整数を文字列として渡している
```

このコードを入力して保存し、以下のコマンドでPyrightで型チェックを実行してみましょう。

```
pyright type_check_example.py
```

実行結果：
```
No errors found.
```

エラーがないことが確認できました。次に、コメントアウトを外して型エラーを確認してみましょう。

```python
# 型エラーになる例のコメントアウトを外す
wrong_message = greet(age)  # 整数を文字列として渡している
```

再度型チェックを実行します。

```
pyright type_check_example.py
```

実行結果：
```
type_check_example.py:21:23 - error: Argument of type "int" cannot be assigned to parameter "name" of type "str" in function "greet" (reportGeneralTypeIssues)
1 error, 0 warnings, 0 informations 
```

Pyrightが型の不一致を検出し、エラーを報告しました。これにより、コードを実行する前に潜在的なバグを発見できます。

### 3. 設定ファイルの作成

Pyrightの設定ファイルを作成することで、プロジェクト固有の設定を定義できます。以下のコマンドを実行して、設定ファイルのテンプレートを生成しましょう。

```
pyright --createconfig
```

実行結果：
```
Created pyright.json file.
```

生成された`pyright.json`ファイルの内容を確認し、必要に応じて編集できます。

### 4. 複雑な型アノテーションの例

より複雑な型アノテーションを使った例を見てみましょう。以下のコードを`advanced_types.py`というファイル名で保存してください。

```python
from typing import Optional, Union, Callable, TypedDict

# Optional型（値がNoneになる可能性がある場合）
user_id: Optional[int] = None

# Union型（複数の型のいずれかになる場合）
mixed_value: Union[int, str] = "test"
mixed_value = 42  # 整数に変更しても型チェックエラーにならない

# Callable型（関数の型を定義）
def process_data(processor: Callable[[str], int], data: str) -> int:
    return processor(data)

# 文字列の長さを返す関数
def get_length(s: str) -> int:
    return len(s)

# 関数を引数として渡す
result = process_data(get_length, "Pythonプログラミング")
print(f"結果: {result}")

# TypedDict（辞書の構造を定義）
class UserProfile(TypedDict):
    name: str
    age: int
    is_active: bool

# TypedDictを使用
user: UserProfile = {
    "name": "山田太郎",
    "age": 30,
    "is_active": True
}

# 型エラーになる例（コメントアウトを外すとエラーになります）
# invalid_user: UserProfile = {
#     "name": "鈴木一郎",
#     "age": "25",  # 文字列を整数型に割り当てようとしている
#     "is_active": True
# }
```

このコードを入力して保存し、Pyrightで型チェックを実行してみましょう。

```
pyright advanced_types.py
```

実行結果：
```
No errors found.
```

次に、コメントアウトを外して型エラーを確認してみましょう。

```python
# 型エラーになる例のコメントアウトを外す
invalid_user: UserProfile = {
    "name": "鈴木一郎",
    "age": "25",  # 文字列を整数型に割り当てようとしている
    "is_active": True
}
```

再度型チェックを実行します。

```
pyright advanced_types.py
```

実行結果：
```
advanced_types.py:35:11 - error: Expression of type "str" cannot be assigned to declared type "int" (reportGeneralTypeIssues)
1 error, 0 warnings, 0 informations
```

Pyrightが辞書内の型不一致を検出しました。

### 5. VSCodeでのPyrightの活用

VSCodeを使用している場合、Pyright拡張機能をインストールすることで、リアルタイムに型チェックを行うことができます。以下の手順で設定してみましょう。

1. VSCodeを開く
2. 拡張機能タブ（Ctrl+Shift+X）を開く
3. 検索バーに「Pyright」と入力
4. Microsoft公式のPyright拡張機能をインストール

これにより、コードを書きながらリアルタイムで型エラーを確認できるようになります。

### 6. strict modeの使用

Pyrightはstrict modeを使用することで、より厳格な型チェックを行うことができます。以下のコマンドを実行してみましょう。

```
pyright --strict advanced_types.py
```

実行結果（エラーが増えることがあります）：
```
advanced_types.py:5:1 - error: Type annotation is missing for variable "mixed_value" (reportMissingTypeArgument)
advanced_types.py:28:1 - error: Type annotation is missing for variable "user" (reportMissingTypeArgument)
2 errors, 0 warnings, 0 informations
```

このように、strictモードではより厳密な型チェックが行われます。

## まとめ

Pyrightは強力な静的型チェックツールであり、以下のメリットがあります：

1. コードを実行する前に型関連のエラーを検出
2. コードの品質と信頼性の向上
3. IDEと連携したリアルタイムの型チェック
4. さまざまな複雑な型アノテーションのサポート

これらの基本操作を覚えることで、より安全で堅牢なPythonコードを書くことができます。
