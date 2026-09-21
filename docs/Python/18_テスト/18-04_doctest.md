# Pythonのdoctest入門

## 概要
doctestはPythonの標準ライブラリに含まれるテストツールで、ドキュメント内にテストコードを埋め込むことができます。

## 主要概念
doctestはドキュメント文字列（docstring）内にPythonインタラクティブシェルのようなコードと結果を記述し、それを実行してテストする仕組みです。

## 実践：doctestの基本

### 1. 基本的なdoctestの書き方

以下のコードを`calculator.py`というファイル名で保存してみましょう：

```python
class Cal:
    def add_num_and_double(self, x, y):
        """Add two numbers and double the result
        
        >>> c = Cal()
        >>> c.add_num_and_double(1, 1)
        4
        
        >>> c.add_num_and_double('1', '1')
        Traceback (most recent call last):
        ...
        ValueError
        """
        if type(x) is not int or type(y) is not int:
            raise ValueError
        result = x + y
        result *= 2
        return result


if __name__ == '__main__':
    import doctest
    doctest.testmod()
```

このコードを入力して実行してみましょう：

```
python calculator.py
```

何も表示されない場合は、テストが全て成功しています。詳細を表示したい場合は以下のように`-v`オプションを付けて実行します：

```
python calculator.py -v
```

実行結果：
```
Trying:
    c = Cal()
Expecting nothing
ok
Trying:
    c.add_num_and_double(1, 1)
Expecting:
    4
ok
Trying:
    c.add_num_and_double('1', '1')
Expecting:
    Traceback (most recent call last):
    ...
    ValueError
ok
1 items had no tests:
    __main__
1 items passed all tests:
   3 tests in __main__.Cal.add_num_and_double
3 tests in 2 items.
3 passed and 0 failed.
Test passed.
```

### 2. doctestの解説

上記のコードを詳しく見てみましょう：

- `"""` で囲まれた部分がdocstring（ドキュメント文字列）です
- `>>>` はPythonインタラクティブシェルのプロンプトを表し、その後にテストしたいコードを記述します
- 次の行に期待される出力結果を記述します
- 例外をテストする場合は、`Traceback (most recent call last):` の後に `...` を入れ、最後に例外の種類を記述します

### 3. doctestの実行方法

doctestを実行するには、以下の方法があります：

1. スクリプトに`if __name__ == '__main__'`ブロックを追加する方法：
```python
if __name__ == '__main__':
    import doctest
    doctest.testmod()
```

2. コマンドラインから直接実行する方法：
```
python -m doctest calculator.py
```

3. 詳細な出力を得るには`-v`オプションを追加：
```
python -m doctest -v calculator.py
```

### 4. テストケースの追加

新しいテストケースを追加してみましょう。以下のコードを`calculator.py`に追加します：

```python
class Cal:
    def add_num_and_double(self, x, y):
        """Add two numbers and double the result
        
        >>> c = Cal()
        >>> c.add_num_and_double(1, 1)
        4
        
        >>> c.add_num_and_double(2, 3)
        10
        
        >>> c.add_num_and_double('1', '1')
        Traceback (most recent call last):
        ...
        ValueError
        
        >>> c.add_num_and_double(1, '1')
        Traceback (most recent call last):
        ...
        ValueError
        """
        if type(x) is not int or type(y) is not int:
            raise ValueError
        result = x + y
        result *= 2
        return result


if __name__ == '__main__':
    import doctest
    doctest.testmod()
```

新しく追加したテストケースは：
1. `c.add_num_and_double(2, 3)` が `10` を返すことを確認
2. `c.add_num_and_double(1, '1')` が `ValueError` を発生させることを確認

このコードを入力して実行してみましょう：

```
python calculator.py -v
```

すべてのテストケースが成功すれば、doctestの基本的な使い方は理解できています。

### 5. doctestの利点

- コードとテストを一箇所に書けるため、ドキュメントが常に最新の状態を保ちやすい
- 例示的なコード使用法を示しながら同時にテストができる
- シンプルで導入コストが低い
- モジュールの使い方を学ぶ際の参考になる

### 6. 注意点

- 複雑なテストには向かない（その場合はunittestやpytestを検討）
- 出力の形式が完全に一致する必要がある（スペースや改行も含む）
- 実行順序に依存するテストには注意が必要
