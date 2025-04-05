# Python辞書内包表記

## 概要
辞書内包表記は、コードを簡潔に書くためのPythonの強力な機能です。

## 理論
辞書内包表記は、反復可能なオブジェクトから要素を取り出して新しい辞書を作成する簡潔な方法です。

## 実践例

### 基本的な辞書作成

以下のコードを入力して実行してみましょう：

```python
# 通常の方法で辞書を作成
weekdays = ['月', '火', '水']
drinks = ['コーヒー', '牛乳', '水']

# 従来の方法（forループを使用）
drink_dict = {}
for day, drink in zip(weekdays, drinks):
    drink_dict[day] = drink

print("従来の方法で作成した辞書:")
print(drink_dict)
```

**実行結果:**
```
従来の方法で作成した辞書:
{'月': 'コーヒー', '火': '牛乳', '水': '水'}
```

### 辞書内包表記を使用

以下のコードを入力して実行してみましょう：

```python
# 辞書内包表記を使用
weekdays = ['月', '火', '水']
drinks = ['コーヒー', '牛乳', '水']

# 辞書内包表記
drink_dict = {day: drink for day, drink in zip(weekdays, drinks)}

print("辞書内包表記で作成した辞書:")
print(drink_dict)
```

**実行結果:**
```
辞書内包表記で作成した辞書:
{'月': 'コーヒー', '火': '牛乳', '水': '水'}
```

### 推奨される簡潔な方法

以下のコードを入力して実行してみましょう：

```python
# より簡潔な方法（dict + zip）
weekdays = ['月', '火', '水']
drinks = ['コーヒー', '牛乳', '水']

# dictコンストラクタとzipを使用
drink_dict = dict(zip(weekdays, drinks))

print("dict + zipで作成した辞書:")
print(drink_dict)
```

**実行結果:**
```
dict + zipで作成した辞書:
{'月': 'コーヒー', '火': '牛乳', '水': '水'}
```

### 条件付き辞書内包表記

以下のコードを入力して実行してみましょう：

```python
# 条件付き辞書内包表記
numbers = [1, 2, 3, 4, 5]
# 偶数の数値に対してその2乗を値とする辞書を作成
even_squares = {num: num**2 for num in numbers if num % 2 == 0}

print("条件付き辞書内包表記で作成した辞書:")
print(even_squares)
```

**実行結果:**
```
条件付き辞書内包表記で作成した辞書:
{2: 4, 4: 16}
```
