# Pydanticチュートリアル

## 概要
Pydanticはデータ検証とデータ設定管理のPythonライブラリで、Pythonの型アノテーションを活用して強力なデータバリデーションを提供します。

## 主要概念
Pydanticの中心的な概念は「BaseModel」クラスで、これを継承してフィールドの型や制約を定義し、データ検証と変換を行います。

## 基本的な使い方

### 1. インストール方法

まずはPydanticをインストールしましょう。以下のコマンドをターミナルに入力して実行してみましょう：

```bash
pip install pydantic
```

### 2. 基本的なモデル定義

最初にPydanticのBaseModelを使って簡単なモデルを定義してみましょう。以下のコードを入力して実行してみましょう：

```python
# basic_model.py
from pydantic import BaseModel
from typing import Optional

# ユーザーモデルを定義
class User(BaseModel):
    # 必須フィールド
    id: int
    name: str
    # 任意フィールド（デフォルト値あり）
    age: Optional[int] = None
    is_active: bool = True

# モデルのインスタンスを作成
user1 = User(id=1, name="田中太郎")
print(user1)

# すべてのフィールドを指定
user2 = User(id=2, name="佐藤花子", age=25, is_active=False)
print(user2)

# 辞書からモデルを作成
user_data = {"id": 3, "name": "鈴木一郎", "age": 30}
user3 = User(**user_data)
print(user3)
```

このコードを入力して実行してみましょう。実行結果は次のようになります：

```
id=1 name='田中太郎' age=None is_active=True
id=2 name='佐藤花子' age=25 is_active=False
id=3 name='鈴木一郎' age=30 is_active=True
```

解説：
- `BaseModel`を継承してモデルクラスを定義しています
- 型アノテーションを使ってフィールドの型を指定しています
- `Optional[int] = None`で任意のフィールドを定義しています
- デフォルト値を指定できます（`is_active = True`）
- インスタンス作成時に不足している任意フィールドは自動的にデフォルト値が使われます

### 3. バリデーションの基本

Pydanticの大きな特徴はデータバリデーションです。以下のコードを入力して実行してみましょう：

```python
# validation_basics.py
from pydantic import BaseModel, ValidationError

class Product(BaseModel):
    name: str
    price: float
    in_stock: bool = True

try:
    # 正しいデータ型
    product1 = Product(name="ノートパソコン", price=98000)
    print(f"成功: {product1}")

    # 数値は自動変換される
    product2 = Product(name="マウス", price="3500")
    print(f"価格の型変換: {product2.price}（型: {type(product2.price).__name__}）")
    
    # 型変換できない場合はエラー
    product3 = Product(name="キーボード", price="とても高い")
    print("この行は表示されません")

except ValidationError as e:
    print(f"バリデーションエラー: {e}")
```

このコードを入力して実行してみましょう。実行結果は次のようになります：

```
成功: name='ノートパソコン' price=98000.0 in_stock=True
価格の型変換: 3500.0（型: float）
バリデーションエラー: 1 validation error for Product
price
  value is not a valid float (type=type_error.float)
```

解説：
- Pydanticは可能であれば自動的に型変換を行います（例: "3500" → 3500.0）
- 型変換できない場合は`ValidationError`が発生します
- エラーメッセージには具体的な問題点が記載されます

### 4. バリデーション制約の追加

より詳細なバリデーションルールを設定するには、Pydanticのフィールド検証機能を使います。以下のコードを入力して実行してみましょう：

```python
# validation_constraints.py
from pydantic import BaseModel, Field, EmailStr, validator
from typing import List
import re

# EmailStrを使うにはpydantic[email]が必要
# pip install pydantic[email]

class User(BaseModel):
    username: str = Field(..., min_length=3, max_length=20)
    email: EmailStr
    age: int = Field(None, ge=0, lt=120)  # 0以上120未満
    tags: List[str] = []
    
    # カスタムバリデーター
    @validator('username')
    def username_alphanumeric(cls, v):
        if not re.match(r'^[a-zA-Z0-9_]+$', v):
            raise ValueError('ユーザー名は英数字とアンダースコアのみ使用できます')
        return v

try:
    # 有効なデータ
    user1 = User(username="tanaka_123", email="tanaka@example.com", age=25)
    print(f"有効なユーザー: {user1}")
    
    # 無効なデータ（年齢が範囲外）
    user2 = User(username="suzuki_123", email="suzuki@example.com", age=150)
    
except ValidationError as e:
    print(f"バリデーションエラー: {e}")

try:
    # 無効なユーザー名（特殊文字を含む）
    user3 = User(username="user@123", email="user@example.com")
    
except ValidationError as e:
    print(f"ユーザー名エラー: {e}")
```

このコードを入力して実行してみましょう。実行結果は次のようになります：

```
有効なユーザー: username='tanaka_123' email='tanaka@example.com' age=25 tags=[]
バリデーションエラー: 1 validation error for User
age
  ensure this value is less than 120 (type=value_error.number.not_lt; limit_value=120)
ユーザー名エラー: 1 validation error for User
username
  ユーザー名は英数字とアンダースコアのみ使用できます (type=value_error)
```

解説：
- `Field()`を使って詳細な制約を指定できます
- `min_length`, `max_length`, `ge`（以上）, `lt`（未満）などの制約が使えます
- `EmailStr`は電子メールの形式を検証します
- カスタムバリデーターで独自のバリデーションロジックを実装できます

### 5. ネストしたモデル

モデル内に他のモデルをネストすることもできます。以下のコードを入力して実行してみましょう：

```python
# nested_models.py
from pydantic import BaseModel
from typing import List, Optional

class Address(BaseModel):
    street: str
    city: str
    postal_code: str
    
class OrderItem(BaseModel):
    product_name: str
    quantity: int
    price_per_unit: float
    
    def total_price(self) -> float:
        return self.quantity * self.price_per_unit

class Order(BaseModel):
    order_id: str
    customer_name: str
    address: Address
    items: List[OrderItem]
    shipping_cost: float = 500.0
    
    def total_amount(self) -> float:
        items_total = sum(item.total_price() for item in self.items)
        return items_total + self.shipping_cost

# データを作成
order_data = {
    "order_id": "ORD-2023-001",
    "customer_name": "山田太郎",
    "address": {
        "street": "桜町3-4-5",
        "city": "東京都渋谷区",
        "postal_code": "150-0001"
    },
    "items": [
        {"product_name": "コーヒーカップ", "quantity": 2, "price_per_unit": 1500},
        {"product_name": "ティーポット", "quantity": 1, "price_per_unit": 3000}
    ]
}

# モデルのインスタンスを作成
order = Order(**order_data)

# データにアクセス
print(f"注文ID: {order.order_id}")
print(f"顧客名: {order.customer_name}")
print(f"配送先: {order.address.city} {order.address.street}")

# 注文内容の表示
print("\n注文内容:")
for i, item in enumerate(order.items, 1):
    print(f"{i}. {item.product_name} x {item.quantity}個 = {item.total_price()}円")

# 合計金額
print(f"\n小計: {sum(item.total_price() for item in order.items)}円")
print(f"送料: {order.shipping_cost}円")
print(f"合計: {order.total_amount()}円")
```

このコードを入力して実行してみましょう。実行結果は次のようになります：

```
注文ID: ORD-2023-001
顧客名: 山田太郎
配送先: 東京都渋谷区 桜町3-4-5

注文内容:
1. コーヒーカップ x 2個 = 3000.0円
2. ティーポット x 1個 = 3000.0円

小計: 6000.0円
送料: 500.0円
合計: 6500.0円
```

解説：
- `Address`と`OrderItem`はネストされたモデルとして定義されています
- `Order`モデルはこれらを組み合わせて複雑なデータ構造を表現しています
- ネストされたデータも自動的にバリデーションされます
- モデルにメソッドを追加して、データに基づく計算を行うこともできます

### 6. 辞書・JSONとの相互変換

Pydanticモデルは辞書やJSONとの変換が簡単にできます。以下のコードを入力して実行してみましょう：

```python
# conversion.py
from pydantic import BaseModel
import json
from typing import List, Optional

class Tag(BaseModel):
    id: int
    name: str

class BlogPost(BaseModel):
    title: str
    content: str
    author: str
    tags: List[Tag]
    published: bool = False
    view_count: Optional[int] = 0

# モデルのインスタンスを作成
post = BlogPost(
    title="Pydanticの使い方",
    content="Pydanticは素晴らしいライブラリです...",
    author="プログラミング太郎",
    tags=[
        Tag(id=1, name="Python"),
        Tag(id=2, name="Pydantic"),
        Tag(id=3, name="チュートリアル")
    ]
)

# モデルを辞書に変換
post_dict = post.dict()
print("辞書への変換:")
print(json.dumps(post_dict, ensure_ascii=False, indent=2))

# 辞書からモデルを作成
new_post = BlogPost(**post_dict)
print("\n辞書から作成したモデル:")
print(new_post)

# モデルをJSONに変換
post_json = post.json(ensure_ascii=False, indent=2)
print("\nJSONへの変換:")
print(post_json)

# JSONからモデルを作成
json_data = json.loads(post_json)
another_post = BlogPost(**json_data)
print("\nJSONから作成したモデル:")
print(another_post)

# 一部のフィールドだけを辞書に変換
partial_dict = post.dict(include={"title", "author", "tags"})
print("\n一部フィールドだけの辞書:")
print(json.dumps(partial_dict, ensure_ascii=False, indent=2))

# ネストしたモデルを除外
exclude_nested = post.dict(exclude={"tags"})
print("\nタグを除外した辞書:")
print(json.dumps(exclude_nested, ensure_ascii=False, indent=2))
```

このコードを入力して実行してみましょう。実行結果は次のようになります：

```
辞書への変換:
{
  "title": "Pydanticの使い方",
  "content": "Pydanticは素晴らしいライブラリです...",
  "author": "プログラミング太郎",
  "tags": [
    {
      "id": 1,
      "name": "Python"
    },
    {
      "id": 2,
      "name": "Pydantic"
    },
    {
      "id": 3,
      "name": "チュートリアル"
    }
  ],
  "published": false,
  "view_count": 0
}

辞書から作成したモデル:
title='Pydanticの使い方' content='Pydanticは素晴らしいライブラリです...' author='プログラミング太郎' tags=[Tag(id=1, name='Python'), Tag(id=2, name='Pydantic'), Tag(id=3, name='チュートリアル')] published=False view_count=0

JSONへの変換:
{
  "title": "Pydanticの使い方",
  "content": "Pydanticは素晴らしいライブラリです...",
  "author": "プログラミング太郎",
  "tags": [
    {
      "id": 1,
      "name": "Python"
    },
    {
      "id": 2,
      "name": "Pydantic"
    },
    {
      "id": 3,
      "name": "チュートリアル"
    }
  ],
  "published": false,
  "view_count": 0
}

JSONから作成したモデル:
title='Pydanticの使い方' content='Pydanticは素晴らしいライブラリです...' author='プログラミング太郎' tags=[Tag(id=1, name='Python'), Tag(id=2, name='Pydantic'), Tag(id=3, name='チュートリアル')] published=False view_count=0

一部フィールドだけの辞書:
{
  "title": "Pydanticの使い方",
  "author": "プログラミング太郎",
  "tags": [
    {
      "id": 1,
      "name": "Python"
    },
    {
      "id": 2,
      "name": "Pydantic"
    },
    {
      "id": 3,
      "name": "チュートリアル"
    }
  ]
}

タグを除外した辞書:
{
  "title": "Pydanticの使い方",
  "content": "Pydanticは素晴らしいライブラリです...",
  "author": "プログラミング太郎",
  "published": false,
  "view_count": 0
}
```

解説：
- `.dict()`メソッドでモデルを辞書に変換できます
- `.json()`メソッドでモデルをJSON文字列に変換できます
- 辞書やJSONからモデルを作成するには、アンパック演算子（`**`）を使います
- `include`や`exclude`パラメータで特定のフィールドだけを含めたり除外したりできます

### 7. 設定クラスとConfig

Pydanticのモデルの動作をカスタマイズするには、`Config`クラスを使います。以下のコードを入力して実行してみましょう：

```python
# config_options.py
from pydantic import BaseModel, validator
from typing import Optional
from datetime import datetime

class UserProfile(BaseModel):
    user_id: int
    username: str
    nickname: Optional[str] = None
    created_at: datetime = None
    
    # カスタムバリデーター
    @validator('created_at', pre=True, always=True)
    def set_created_at(cls, v):
        return v or datetime.now()
    
    class Config:
        # 未知のフィールドを許可しない
        extra = "forbid"
        
        # フィールド名のエイリアス（別名）
        fields = {
            'user_id': {'alias': 'id'},
            'username': {'alias': 'login'}
        }
        
        # スキーマの追加情報
        schema_extra = {
            "example": {
                "user_id": 123,
                "username": "example_user",
                "nickname": "ユーザー1"
            }
        }

try:
    # 通常の方法でインスタンス作成
    user1 = UserProfile(user_id=1, username="tanaka")
    print(f"ユーザー1: {user1}")
    
    # エイリアスを使ったインスタンス作成
    user2 = UserProfile(id=2, login="yamada", nickname="やまちゃん")
    print(f"ユーザー2: {user2}")
    
    # 未知のフィールドを含む（エラーになる）
    user3 = UserProfile(user_id=3, username="suzuki", unknown_field="test")
    print("この行は表示されません")
    
except Exception as e:
    print(f"エラー: {e}")

# モデルの設定情報を表示
print("\nモデルのスキーマ例:")
print(UserProfile.schema()["example"])
```

このコードを入力して実行してみましょう。実行結果は次のようになります：

```
ユーザー1: user_id=1 username='tanaka' nickname=None created_at=2023-04-20 15:30:45.123456
ユーザー2: user_id=2 username='yamada' nickname='やまちゃん' created_at=2023-04-20 15:30:45.234567
エラー: 1 validation error for UserProfile
unknown_field
  extra fields not permitted (type=value_error.extra)

モデルのスキーマ例:
{'user_id': 123, 'username': 'example_user', 'nickname': 'ユーザー1'}
```

解説：
- `Config`クラスを使ってモデルの動作をカスタマイズできます
- `extra = "forbid"`で未知のフィールドを禁止します（他に`"ignore"`や`"allow"`も可能）
- `fields`でフィールド名のエイリアスを定義できます
- `schema_extra`でOpenAPIスキーマの追加情報を定義できます
- `@validator`デコレータで`always=True`を指定すると、値がない場合でも常にバリデーターが実行されます

以上がPydanticの基本的な使い方です。実際にコードを入力して実行しながら理解を深めていきましょう。
