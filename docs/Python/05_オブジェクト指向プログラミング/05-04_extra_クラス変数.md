# Pythonのクラス変数

## 概要
クラス変数はクラス内で定義され、そのクラスのすべてのインスタンスで共有される変数です。

## 主要概念
クラス変数はクラス自体に属し、インスタンス変数とは異なり、すべてのインスタンス間で共有されます。

## 実践例

### 例1: クラス変数とインスタンス変数の違い

以下のコードを入力して実行してみましょう：

```python
# インスタンス変数の例
class Person:
    def __init__(self, name):
        self.kind = 'human'  # インスタンス変数
        self.name = name     # インスタンス変数

    def who_are_you(self):
        print(self.name, self.kind)


print("インスタンス変数の例:")
a = Person('Alice')
a.who_are_you()  # Alice human

b = Person('Bob')
b.who_are_you()  # Bob human
```

**実行結果:**
```
インスタンス変数の例:
Alice human
Bob human
```

**解説:**
上記の例では、`kind`と`name`は両方ともインスタンス変数です。各インスタンスが作成されるときに、`__init__`メソッド内で初期化されます。

次に、クラス変数を使った例を見てみましょう：

```python
# クラス変数の例
class Person:
    kind = 'human'  # クラス変数

    def __init__(self, name):
        self.name = name  # インスタンス変数

    def who_are_you(self):
        print(self.name, self.kind)


print("\nクラス変数の例:")
a = Person('Alice')
a.who_are_you()  # Alice human

b = Person('Bob')
b.who_are_you()  # Bob human
```

**実行結果:**
```
クラス変数の例:
Alice human
Bob human
```

**解説:**
この例では、`kind`はクラス変数として定義されています。この変数はクラス全体で共有され、すべてのインスタンスからアクセスできます。一方、`name`はインスタンス変数です。

### 例2: クラス変数の共有による問題

クラス変数が共有されることで起こりうる問題を見てみましょう：

```python
print("\n共有されるクラス変数の例:")
class WordCollector:
    words = []  # クラス変数

    def add_word(self, word):
        self.words.append(word)


# 最初のインスタンスを作成
c = WordCollector()
c.add_word('単語1')
c.add_word('単語2')
print(f"cのwords: {c.words}")  # ['単語1', '単語2']

# 2つ目のインスタンスを作成
d = WordCollector()
d.add_word('単語3')
d.add_word('単語4')
print(f"dのwords: {d.words}")  # ['単語1', '単語2', '単語3', '単語4']
print(f"cのwords: {c.words}")  # ['単語1', '単語2', '単語3', '単語4'] - 同じ内容が表示される
```

**実行結果:**
```
共有されるクラス変数の例:
cのwords: ['単語1', '単語2']
dのwords: ['単語1', '単語2', '単語3', '単語4']
cのwords: ['単語1', '単語2', '単語3', '単語4']
```

**解説:**
この例では、クラス変数`words`がすべてのインスタンス間で共有されるため、一方のインスタンスが変更を加えると、それがもう一方のインスタンスにも影響します。`d`が単語を追加すると、`c`の`words`リストにもその単語が追加されます。

### 例3: インスタンス変数を使った解決策

クラス変数の共有問題を解決するために、インスタンス変数を使う方法を見てみましょう：

```python
print("\nインスタンス変数を使った解決例:")
class WordCollector:
    def __init__(self):
        self.words = []  # インスタンス変数として初期化

    def add_word(self, word):
        self.words.append(word)


# 最初のインスタンスを作成
c = WordCollector()
c.add_word('単語1')
c.add_word('単語2')
print(f"cのwords: {c.words}")  # ['単語1', '単語2']

# 2つ目のインスタンスを作成
d = WordCollector()
d.add_word('単語3')
d.add_word('単語4')
print(f"dのwords: {d.words}")  # ['単語3', '単語4'] - 独立したリスト
print(f"cのwords: {c.words}")  # ['単語1', '単語2'] - 変更されていない
```

**実行結果:**
```
インスタンス変数を使った解決例:
cのwords: ['単語1', '単語2']
dのwords: ['単語3', '単語4']
cのwords: ['単語1', '単語2']
```

**解説:**
この例では、`words`リストをインスタンス変数として`__init__`メソッド内で初期化しています。これにより、各インスタンスが独自の`words`リストを持つようになり、一方のインスタンスでの変更が他方に影響することはありません。

## まとめ

1. **クラス変数**はクラス定義内、メソッドの外で定義され、クラスの全インスタンス間で共有されます。
2. **インスタンス変数**は通常`__init__`メソッド内で`self`を使って定義され、各インスタンスごとに独立しています。
3. 変更可能なオブジェクト（リストなど）をクラス変数として使用する場合は、意図しない共有問題に注意が必要です。
4. 各インスタンスが独自のデータを持つべき場合は、インスタンス変数を使用しましょう。
