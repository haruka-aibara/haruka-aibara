# Pythonの書き方ガイド

## 1. importの正しい方法

importは適切に行うことでコードの可読性と保守性が向上します。

importには以下の原則に従いましょう：

### importの順序を守る

```python
# 1. 標準ライブラリ
import os
import sys

# 2. サードパーティライブラリ
import numpy
import pandas

# 3. ローカルパッケージ
import mypackage

# 4. ローカルモジュール
import mymodule
```

このコードを入力して実行してみましょう。エラーは出ませんが、適切な順序でimportすることでコードの整理整頓ができます。

### 関数レベルでのimportは避ける

```python
# 良くない例
def my_function():
    import os  # ここでimportすると、どのモジュールの関数を使用しているか分かりにくい
    path = os.path.join('folder', 'file.txt')
    return path

# 良い例
import os  # ファイルの先頭でimport

def my_function():
    path = os.path.join('folder', 'file.txt')
    return path
```

このコードを入力して実行してみましょう。どちらも動作しますが、ファイルの先頭でimportする方が依存関係が明確になります。

## 2. 例外処理の適切な書き方

例外処理は具体的に行うことでバグの特定と対処が容易になります。

### すべての例外を拾う書き方は避ける

```python
# 良くない例 - 全ての例外を拾ってしまう
try:
    with open('存在しないファイル.txt', 'r') as f:
        content = f.read()
except Exception as exc:
    print(f"エラーが発生しました: {exc}")  # どんなエラーでも同じ処理をしてしまう

# 良い例 - 具体的な例外を処理する
try:
    with open('存在しないファイル.txt', 'r') as f:
        content = f.read()
except FileNotFoundError:
    print("ファイルが見つかりませんでした")
except PermissionError:
    print("ファイルを開く権限がありません")
```

このコードを入力して実行してみましょう。「ファイルが見つかりませんでした」と表示されます。具体的な例外を処理することで、問題の特定が容易になります。

### カスタム例外クラスの作成

```python
# 独自の例外クラスを作成
class MainError(Exception):
    pass

def main():
    raise MainError('カスタムエラーが発生しました')

# 例外処理
try:
    main()
except MainError as e:
    print(f"メインエラーをキャッチしました: {e}")
```

このコードを入力して実行してみましょう。「メインエラーをキャッチしました: カスタムエラーが発生しました」と表示されます。カスタム例外を使うことで、アプリケーション固有のエラー処理が可能になります。

## 3. 辞書操作の効率的な方法

辞書操作は適切な方法を使うことでコードの効率が向上します。

### キーの存在確認

```python
# 辞書の作成
d = {'key1': 'value1', 'key2': 'value2'}

# 良い方法 - 直接 in 演算子を使う
if 'key1' in d:
    print('key1が存在します')

# 良くない方法 - 不要なメソッド呼び出し
if 'key1' in d.keys():
    print('key1が存在します（非効率的な方法）')
```

このコードを入力して実行してみましょう。どちらも「key1が存在します」と表示されますが、最初の方法はより効率的です。`.keys()`メソッドを呼び出すと余分な処理が発生するため避けましょう。

## 4. 変数名の適切な選択

変数名は目的を明確に示すことでコードの可読性が向上します。

### 分かりやすい変数名

```python
# 分かりやすい変数名の例
ranking = {'Alice': 95, 'Bob': 87, 'Charlie': 92}

# 良い例 - 意味が明確な変数名
for name, score in ranking.items():
    print(f"{name}さんのスコア: {score}点")
```

このコードを入力して実行してみましょう。各人の名前とスコアが表示されます。変数名が何を表しているか明確なので、コードが読みやすくなります。

### 短い変数名の適切な使用場面

```python
# 短いループや簡単な処理では短い変数名も許容される
d = {'a': 1, 'b': 2, 'c': 3}

# 短い変数名でも問題ない場合
for k, v in d.items():
    print(f"キー: {k}, 値: {v}")
```

このコードを入力して実行してみましょう。辞書の各キーと値が表示されます。シンプルな処理では短い変数名も許容されます。

## 5. リストの生成とジェネレーター

メモリ効率を考慮したデータ生成方法を選ぶことが重要です。

### リストを返す関数

```python
# リストを作成して返す関数
def create_numbers_list():
    numbers = []
    for i in range(10):
        numbers.append(i)
    return numbers

# 関数の結果を使用
for num in create_numbers_list():
    print(f"数値: {num}")
```

このコードを入力して実行してみましょう。0から9までの数値が表示されます。この方法ではすべての要素がメモリに保持されます。

### ジェネレーターを使用した効率的な方法

```python
# ジェネレーターを使用する関数 - メモリ効率が良い
def generate_numbers():
    for i in range(10):
        yield i

# ジェネレーターの結果を使用
for num in generate_numbers():
    print(f"生成された数値: {num}")
```

このコードを入力して実行してみましょう。同じく0から9までの数値が表示されますが、一度に1つの値だけを生成するのでメモリ使用量が少なくなります。

## 6. lambdaの適切な使用

簡潔な関数が必要な場合、lambdaは強力なツールです。

### 関数を引数として渡す場合

```python
# 関数を引数として受け取る関数
def apply_operation(f, value):
    return f(value)

# 通常の関数定義
def double(x):
    return x * 2

def triple(x):
    return x * 3

# 通常の関数を使用
print(f"倍にした結果: {apply_operation(double, 10)}")  # 20

# lambdaを使用 - より簡潔
print(f"3倍にした結果: {apply_operation(lambda x: x * 3, 10)}")  # 30
print(f"2乗した結果: {apply_operation(lambda x: x ** 2, 10)}")  # 100
```

このコードを入力して実行してみましょう。結果として「倍にした結果: 20」「3倍にした結果: 30」「2乗した結果: 100」が表示されます。lambdaを使用することで、一時的な簡単な関数を簡潔に記述できます。

## 7. 条件式（三項演算子）

条件に基づいて値を割り当てる簡潔な方法です。

```python
# 条件式の例
y = None
x = 1 if y else 2
print(f"yがNoneの場合、xは: {x}")  # 2

y = "値があります"
x = 1 if y else 2
print(f"yに値がある場合、xは: {x}")  # 1
```

このコードを入力して実行してみましょう。最初の場合はyがNoneなのでxは2、次の場合はyに値があるのでxは1になります。条件式はif-else文を1行で記述できる便利な構文です。

## 8. クロージャーの適切な使用

関数が外部の値を参照する場合、その値の変更に注意が必要です。

### クロージャーの良い例

```python
# クロージャーの適切な使用例
def base(x):
    def plus(y):
        return x + y
    return plus

# クロージャー関数を作成
plus_ten = base(10)
print(f"10 + 5 = {plus_ten(5)}")  # 15
print(f"10 + 20 = {plus_ten(20)}")  # 30
```

このコードを入力して実行してみましょう。結果として「10 + 5 = 15」「10 + 20 = 30」が表示されます。クロージャーが作成された時点のxの値（10）が保持されています。

### クロージャーの問題点

```python
# グローバル変数を使用したクロージャーの問題例
i = 0

def add_num():
    def plus(y):
        return i + y
    return plus

# クロージャー作成時は i = 0
i = 10
plus = add_num()
print(f"現在のiは10、10 + 10 = {plus(10)}")  # 20

# iの値を変更すると結果も変わる
i = 100
print(f"iが100に変更された、100 + 30 = {plus(30)}")  # 130
```

このコードを入力して実行してみましょう。グローバル変数iの値が変わると、クロージャー関数の結果も変わってしまいます。これは混乱の原因になるため、上の例のように引数として値を渡す方が安全です。
