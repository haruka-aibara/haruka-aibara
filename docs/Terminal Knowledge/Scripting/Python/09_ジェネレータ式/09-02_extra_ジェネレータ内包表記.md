# ジェネレータ式（ジェネレータの内包表記）

## 概要
ジェネレータ式はPythonで値を効率的に生成するための簡潔な構文で、メモリ使用量を最小限に抑えながら反復処理が可能です。

## 主要概念
ジェネレータ内包表記はリスト内包表記に似ていますが、括弧`()`で囲まれ、要素を一度に全て生成せず必要に応じて一つずつ値を生成します。

## ジェネレータの基本とジェネレータ式

### 従来のジェネレータ関数

まずは従来のジェネレータ関数の書き方を確認しましょう。

```python
# 従来のジェネレータ関数の定義
def number_generator():
    for i in range(10):
        yield i  # yieldキーワードを使って値を一つずつ生成

# ジェネレータオブジェクトの作成
gen = number_generator()

# next()関数で値を取得
print(next(gen))  # 0
print(next(gen))  # 1
print(next(gen))  # 2
print(next(gen))  # 3
print(next(gen))  # 4
```

このコードを入力して実行してみましょう。ジェネレータは`next()`関数を呼び出すたびに、次の値を生成して返します。

### ジェネレータ式（内包表記）

同じ機能をより簡潔に記述できるのがジェネレータ式です。

```python
# ジェネレータ式の定義
# 括弧()を使うことに注意 - タプルのように見えますが、ジェネレータです
gen_expr = (i for i in range(10))

# next()関数で値を取得
print(next(gen_expr))  # 0
print(next(gen_expr))  # 1
print(next(gen_expr))  # 2
print(next(gen_expr))  # 3
print(next(gen_expr))  # 4
```

このコードを入力して実行してみましょう。ジェネレータ式は`(式 for 変数 in イテラブル)`の形式で記述します。

## ジェネレータ式の応用例

### フィルタリング条件の追加

```python
# 偶数だけを生成するジェネレータ式
even_numbers = (x for x in range(20) if x % 2 == 0)

# 最初の5つの偶数を表示
for _ in range(5):
    print(next(even_numbers))  # 0, 2, 4, 6, 8 が順に表示される
```

このコードを入力して実行してみましょう。条件式を追加することで、特定の条件を満たす値だけを生成できます。

### 複数のfor文を使った例

```python
# 2つのリストの組み合わせを生成するジェネレータ式
coordinates = ((x, y) for x in range(3) for y in range(2))

# 全ての組み合わせを表示
for coord in coordinates:
    print(coord)  # (0,0), (0,1), (1,0), (1,1), (2,0), (2,1) が順に表示される
```

このコードを入力して実行してみましょう。複数のfor文を組み合わせることで、複雑なシーケンスも簡潔に表現できます。

## リスト内包表記とジェネレータ式の違い

```python
import sys

# リスト内包表記（すべての値を一度にメモリに格納）
list_comp = [i for i in range(10000)]

# ジェネレータ式（値を必要に応じて生成）
gen_expr = (i for i in range(10000))

# メモリ使用量の比較
print(f"リスト内包表記のサイズ: {sys.getsizeof(list_comp)} バイト")
print(f"ジェネレータ式のサイズ: {sys.getsizeof(gen_expr)} バイト")

# 両方から最初の5つの値を取得
print("\nリスト内包表記から値を取得:")
for i in range(5):
    print(list_comp[i])

print("\nジェネレータ式から値を取得:")
gen_expr_iter = iter(gen_expr)
for i in range(5):
    print(next(gen_expr_iter))
```

このコードを入力して実行してみましょう。ジェネレータ式はリスト内包表記と比べて大幅にメモリ使用量を抑えられることがわかります。

## まとめ

ジェネレータ式は:
- `(式 for 変数 in イテラブル [if 条件式])`の形式で記述
- 必要に応じて値を一つずつ生成するため、メモリ効率が良い
- 大量のデータや無限シーケンスを扱う場合に特に有用
- `next()`関数または`for`ループで値を取得

適切な場面でジェネレータ式を活用することで、効率的なPythonプログラムを書くことができます。
