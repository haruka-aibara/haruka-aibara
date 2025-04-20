# Pythonにおける型ヒント（typing）

Pythonの型ヒント（typing）モジュールは、コードの可読性向上とバグ防止に役立つ静的型チェック機能を提供します。

型ヒントはPython 3.5から導入され、コードの意図を明確にし、IDEの補完機能やツールによる型チェックを可能にします。

## 基本的な型ヒント

まずは基本的な型ヒントの使い方から見ていきましょう。

```python
# typing モジュールをインポート
import typing

# 基本的な型ヒントの例
def greeting(name: str) -> str:
    """
    名前を受け取り、挨拶文を返す関数
    引数:
        name: 挨拶する相手の名前
    戻り値:
        挨拶文
    """
    return f"こんにちは、{name}さん！"

# 関数の使用例
message = greeting("田中")
print(message)  # 出力: こんにちは、田中さん！
```

このコードを入力して実行してみましょう。

実行結果:
```
こんにちは、田中さん！
```

上記のコードでは、`name: str` で引数の型を文字列として指定し、`-> str` で戻り値の型も文字列であることを示しています。

## 基本的なデータ型

次に、よく使われる基本的なデータ型を見てみましょう。

```python
from typing import List, Dict, Tuple, Set, Optional

# リスト
def sum_numbers(numbers: List[int]) -> int:
    """整数のリストの合計を計算する"""
    return sum(numbers)

# 辞書
def get_user_info(user_data: Dict[str, str]) -> str:
    """ユーザー情報から名前と年齢を取得する"""
    return f"{user_data['name']}さん ({user_data['age']}歳)"

# タプル
def calculate_statistics(values: Tuple[float, ...]) -> Tuple[float, float, float]:
    """数値のタプルから最小値、最大値、平均値を計算する"""
    return min(values), max(values), sum(values) / len(values)

# 集合
def unique_elements(elements: Set[int]) -> int:
    """集合の要素数を返す"""
    return len(elements)

# Optional型（値かNoneを取りうる）
def process_input(text: Optional[str] = None) -> str:
    """テキストを処理する。Noneの場合はデフォルト値を使用"""
    if text is None:
        return "デフォルトテキスト"
    return text.upper()

# 実行例
print(sum_numbers([1, 2, 3, 4, 5]))  # 出力: 15

user = {"name": "佐藤", "age": "30"}
print(get_user_info(user))  # 出力: 佐藤さん (30歳)

stats = calculate_statistics((1.5, 2.5, 3.5, 4.5))
print(f"最小値: {stats[0]}, 最大値: {stats[1]}, 平均値: {stats[2]}")  # 出力: 最小値: 1.5, 最大値: 4.5, 平均値: 3.0

print(unique_elements({1, 2, 3, 2, 1}))  # 出力: 3

print(process_input())  # 出力: デフォルトテキスト
print(process_input("こんにちは"))  # 出力: こんにちは
```

このコードを入力して実行してみましょう。

実行結果:
```
15
佐藤さん (30歳)
最小値: 1.5, 最大値: 4.5, 平均値: 3.0
3
デフォルトテキスト
こんにちは
```

## Union型とAny型

複数の型を許容する場合や、任意の型を許容する場合の指定方法を見てみましょう。

```python
from typing import Union, Any, List

# Union型（複数の型のいずれかを許容）
def process_value(value: Union[int, str]) -> str:
    """整数または文字列を受け取り、文字列として返す"""
    return str(value)

# Any型（任意の型を許容）
def log_data(data: Any) -> None:
    """任意のデータをログとして出力する"""
    print(f"LOG: {data}")

# 複合的な型の例
def process_items(items: List[Union[int, str]]) -> List[str]:
    """整数と文字列が混在するリストを、すべて文字列に変換する"""
    return [str(item) for item in items]

# 実行例
print(process_value(123))      # 出力: 123
print(process_value("hello"))  # 出力: hello

log_data(42)           # 出力: LOG: 42
log_data("テスト")      # 出力: LOG: テスト
log_data([1, 2, 3])    # 出力: LOG: [1, 2, 3]

mixed_items = [1, "二", 3, "四", 5]
print(process_items(mixed_items))  # 出力: ['1', '二', '3', '四', '5']
```

このコードを入力して実行してみましょう。

実行結果:
```
123
hello
LOG: 42
LOG: テスト
LOG: [1, 2, 3]
['1', '二', '3', '四', '5']
```

## 自作クラスと型ヒント

自作クラスを型ヒントとして使用する方法を見てみましょう。

```python
from typing import List, Optional

# ユーザークラスの定義
class User:
    def __init__(self, name: str, age: int):
        self.name = name
        self.age = age
    
    def greeting(self) -> str:
        return f"こんにちは、{self.name}です。{self.age}歳です。"

# ユーザークラスを型として使用
def create_user(name: str, age: int) -> User:
    """ユーザーオブジェクトを作成する"""
    return User(name, age)

def find_adult_users(users: List[User]) -> List[User]:
    """成人ユーザーのリストを返す"""
    return [user for user in users if user.age >= 20]

def get_user_by_name(users: List[User], name: str) -> Optional[User]:
    """名前からユーザーを検索する。見つからない場合はNone"""
    for user in users:
        if user.name == name:
            return user
    return None

# 実行例
user1 = create_user("山田", 25)
user2 = create_user("佐藤", 18)
user3 = create_user("鈴木", 30)

users = [user1, user2, user3]

print(user1.greeting())  # 出力: こんにちは、山田です。25歳です。

# 成人ユーザーのみ取得
adult_users = find_adult_users(users)
for user in adult_users:
    print(f"成人ユーザー: {user.name}")  # 出力: 成人ユーザー: 山田、成人ユーザー: 鈴木

# 名前でユーザーを検索
found_user = get_user_by_name(users, "佐藤")
if found_user:
    print(f"検索結果: {found_user.name}, {found_user.age}歳")  # 出力: 検索結果: 佐藤, 18歳
```

このコードを入力して実行してみましょう。

実行結果:
```
こんにちは、山田です。25歳です。
成人ユーザー: 山田
成人ユーザー: 鈴木
検索結果: 佐藤, 18歳
```

## TypeVar と ジェネリクス

汎用的なコードを書くためのジェネリック型の使い方を見てみましょう。

```python
from typing import TypeVar, List, Dict, Generic

# 型変数の定義
T = TypeVar('T')  # 任意の型を表す型変数

# ジェネリック関数
def first_element(collection: List[T]) -> T:
    """リストの最初の要素を返す"""
    if not collection:
        raise ValueError("空のリストです")
    return collection[0]

# ジェネリッククラス
class Box(Generic[T]):
    def __init__(self, content: T):
        self.content = content
    
    def get_content(self) -> T:
        return self.content
    
    def replace_content(self, new_content: T) -> None:
        self.content = new_content

# 実行例
# 整数リストの最初の要素
numbers = [10, 20, 30]
first_num = first_element(numbers)
print(f"最初の数値: {first_num}")  # 出力: 最初の数値: 10

# 文字列リストの最初の要素
names = ["山田", "佐藤", "鈴木"]
first_name = first_element(names)
print(f"最初の名前: {first_name}")  # 出力: 最初の名前: 山田

# 整数のBox
int_box = Box[int](42)
print(f"Boxの中身: {int_box.get_content()}")  # 出力: Boxの中身: 42
int_box.replace_content(100)
print(f"新しいBoxの中身: {int_box.get_content()}")  # 出力: 新しいBoxの中身: 100

# 文字列のBox
str_box = Box[str]("こんにちは")
print(f"Boxの中身: {str_box.get_content()}")  # 出力: Boxの中身: こんにちは
str_box.replace_content("さようなら")
print(f"新しいBoxの中身: {str_box.get_content()}")  # 出力: 新しいBoxの中身: さようなら
```

このコードを入力して実行してみましょう。

実行結果:
```
最初の数値: 10
最初の名前: 山田
Boxの中身: 42
新しいBoxの中身: 100
Boxの中身: こんにちは
新しいBoxの中身: さようなら
```

## Callable と関数の型ヒント

関数を引数や戻り値として扱う場合の型ヒントを見てみましょう。

```python
from typing import Callable, List, Dict, Any, TypeVar

# 関数の型定義
T = TypeVar('T')
R = TypeVar('R')

# 関数を引数として受け取る関数
def apply_function(func: Callable[[T], R], value: T) -> R:
    """関数を値に適用する"""
    return func(value)

# マッピング関数
def map_values(func: Callable[[T], R], values: List[T]) -> List[R]:
    """関数をリストの各要素に適用する"""
    return [func(value) for value in values]

# テスト用の関数定義
def square(x: int) -> int:
    """数値を二乗する"""
    return x * x

def to_uppercase(s: str) -> str:
    """文字列を大文字に変換する"""
    return s.upper()

# 実行例
# 単一の値に関数を適用
result1 = apply_function(square, 5)
print(f"5の二乗: {result1}")  # 出力: 5の二乗: 25

result2 = apply_function(to_uppercase, "hello")
print(f"大文字変換: {result2}")  # 出力: 大文字変換: HELLO

# リストの各要素に関数を適用
numbers = [1, 2, 3, 4, 5]
squared_numbers = map_values(square, numbers)
print(f"二乗したリスト: {squared_numbers}")  # 出力: 二乗したリスト: [1, 4, 9, 16, 25]

words = ["apple", "banana", "cherry"]
uppercase_words = map_values(to_uppercase, words)
print(f"大文字変換したリスト: {uppercase_words}")  # 出力: 大文字変換したリスト: ['APPLE', 'BANANA', 'CHERRY']
```

このコードを入力して実行してみましょう。

実行結果:
```
5の二乗: 25
大文字変換: HELLO
二乗したリスト: [1, 4, 9, 16, 25]
大文字変換したリスト: ['APPLE', 'BANANA', 'CHERRY']
```

## Python 3.9以降の型ヒント簡略記法

Python 3.9以降では、型ヒントの記法が簡略化されました。

```python
# Python 3.9以降では、typingモジュールからのインポートなしで以下のように書けます
# このコードは Python 3.9以降でのみ動作します

# 従来の書き方
from typing import List, Dict, Tuple, Set, Union

# 従来の書き方による型ヒント
numbers_old: List[int] = [1, 2, 3]
user_old: Dict[str, Union[str, int]] = {"name": "山田", "age": 30}
point_old: Tuple[int, int] = (10, 20)
unique_ids_old: Set[int] = {1, 2, 3}

# Python 3.9以降の簡略記法
numbers_new: list[int] = [1, 2, 3]
user_new: dict[str, str | int] = {"name": "山田", "age": 30}
point_new: tuple[int, int] = (10, 20)
unique_ids_new: set[int] = {1, 2, 3}

# 実行例（値の確認）
print(f"numbers_new: {numbers_new}")  # 出力: numbers_new: [1, 2, 3]
print(f"user_new: {user_new}")  # 出力: user_new: {'name': '山田', 'age': 30}
print(f"point_new: {point_new}")  # 出力: point_new: (10, 20)
print(f"unique_ids_new: {unique_ids_new}")  # 出力: unique_ids_new: {1, 2, 3}
```

このコードはPython 3.9以降でのみ動作します。実行してみると以下のような結果が得られます。

実行結果 (Python 3.9以降):
```
numbers_new: [1, 2, 3]
user_new: {'name': '山田', 'age': 30}
point_new: (10, 20)
unique_ids_new: {1, 2, 3}
```

## まとめ

Pythonの型ヒント（typing）モジュールを使うことで、コードの意図が明確になり、バグを早期に発見しやすくなります。また、IDEの補完機能も向上し、開発効率が上がります。

- 基本的な型ヒント: `str`, `int`, `float`, `bool` など
- コレクション型: `List[T]`, `Dict[K, V]`, `Tuple[T, ...]`, `Set[T]` など
- 特殊な型: `Optional[T]`, `Union[T1, T2]`, `Any` など
- ジェネリック型: `TypeVar`, `Generic[T]` など
- 関数型: `Callable[[ArgType1, ArgType2], ReturnType]` など

型ヒントはコードの実行速度には影響しませんが、コードの品質向上とメンテナンス性の向上に大きく貢献します。
