# Python unittest フレームワーク：自動テストを簡単に

## 1. 概要と重要性
Pythonの`unittest`フレームワークはコードが期待通りに動作することを検証する構造化された方法を提供し、バグを早期に発見し、安心してリファクタリングを行うことができます。

## 2. 主要概念
`unittest`フレームワークは、テストケース（`unittest.TestCase`を継承するクラス）、テストメソッド、アサーション、およびテストフィクスチャ（セットアップ/ティアダウン）を中心に構築されています。

## 3. ステップバイステップガイド（実例付き）

### インストール
インストール不要 - `unittest`はPythonの標準ライブラリに含まれています。

### 最初のテストを作成する

簡単な電卓クラスを作成し、それに対するテストを書いてみましょう：

1. まず、`calculation.py`というファイルを作成し、以下のコードを入力します：

```python
class Cal():
    def add_num_and_double(self, x, y):
        """2つの数値を足して、結果を2倍にする"""
        if type(x) is not int or type(y) is not int:
            raise ValueError
        result = x + y
        result *= 2
        return result
```

2. 次に、同じディレクトリに`test_calculation.py`というテストファイルを作成します：

```python
import unittest
import calculation

class CalTest(unittest.TestCase):
    def test_add_num_and_double(self):
        cal = calculation.Cal()
        self.assertEqual(cal.add_num_and_double(1, 1), 4)

if __name__ == '__main__':
    unittest.main()
```

3. 以下のコマンドでテストを実行します：

```
python test_calculation.py
```

期待される出力：
```
.
----------------------------------------------------------------------
Ran 1 test in 0.001s

OK
```

`.`はテストが成功したことを示します。失敗した場合は代わりに`F`が表示されます。

### 例外のテスト

整数以外の入力が与えられたときに`ValueError`が発生することを確認するテストを追加しましょう：

```python
import unittest
import calculation

class CalTest(unittest.TestCase):
    def test_add_num_and_double(self):
        cal = calculation.Cal()
        self.assertEqual(cal.add_num_and_double(1, 1), 4)
        
    def test_add_num_and_double_raise(self):
        cal = calculation.Cal()
        with self.assertRaises(ValueError):
            cal.add_num_and_double('1', '1')

if __name__ == '__main__':
    unittest.main()
```

`python test_calculation.py`でこのテストを実行してください。以下のような出力が表示されるはずです：

```
..
----------------------------------------------------------------------
Ran 2 tests in 0.001s

OK
```

### セットアップとティアダウンの使用

効率性のために、`setUp()`と`tearDown()`メソッドを使用してコードの繰り返しを避けることができます：

```python
import unittest
import calculation

class CalTest(unittest.TestCase):
    def setUp(self):
        print('setup')
        self.cal = calculation.Cal()
        
    def tearDown(self):
        print('clean up')
        del self.cal
        
    def test_add_num_and_double(self):
        self.assertEqual(self.cal.add_num_and_double(1, 1), 4)
        
    def test_add_num_and_double_raise(self):
        with self.assertRaises(ValueError):
            self.cal.add_num_and_double('1', '1')

if __name__ == '__main__':
    unittest.main()
```

より詳細な出力を見るために`-v`フラグを付けて実行してみましょう：

```
python test_calculation.py -v
```

期待される出力：
```
test_add_num_and_double (__main__.CalTest) ... setup
clean up
ok
test_add_num_and_double_raise (__main__.CalTest) ... setup
clean up
ok

----------------------------------------------------------------------
Ran 2 tests in 0.001s

OK
```

### テストのスキップ

特定のテストをスキップする必要がある場合があります。その方法を見てみましょう：

```python
import unittest
import calculation

release_name = 'lesson'  # 環境に基づいて変更される可能性があります

class CalTest(unittest.TestCase):
    def setUp(self):
        print('setup')
        self.cal = calculation.Cal()
        
    def tearDown(self):
        print('clean up')
        del self.cal
        
    @unittest.skip('skip!')
    def test_add_num_and_double(self):
        self.assertEqual(self.cal.add_num_and_double(1, 1), 4)
        
    @unittest.skipIf(release_name == 'lesson', 'skip!')
    def test_add_num_and_double_raise(self):
        with self.assertRaises(ValueError):
            self.cal.add_num_and_double('1', '1')

if __name__ == '__main__':
    unittest.main()
```

以下のコマンドで実行してください：

```
python test_calculation.py -v
```

期待される出力：
```
test_add_num_and_double (__main__.CalTest) ... skipped 'skip!'
test_add_num_and_double_raise (__main__.CalTest) ... skipped 'skip!'

----------------------------------------------------------------------
Ran 2 tests in 0.000s

OK (skipped=2)
```

### 一般的なアサーション

最も役立つアサーションのいくつかを紹介します：

```python
import unittest

class AssertionsTest(unittest.TestCase):
    def test_assertions(self):
        # 等価性のテスト
        self.assertEqual(1, 1)
        
        # 不等価性のテスト
        self.assertNotEqual(1, 2)
        
        # ブール値のテスト
        self.assertTrue(True)
        self.assertFalse(False)
        
        # アイテムがコレクションに含まれているかのテスト
        self.assertIn(1, [1, 2, 3])
        
        # アイテムがコレクションに含まれていないかのテスト
        self.assertNotIn(4, [1, 2, 3])
        
        # オブジェクトがあるクラスのインスタンスであるかのテスト
        self.assertIsInstance(1, int)
        
        # オブジェクトがNoneであるかのテスト
        x = None
        self.assertIsNone(x)
        
        # オブジェクトがNoneでないかのテスト
        y = 1
        self.assertIsNotNone(y)

if __name__ == '__main__':
    unittest.main()
```

これを`test_assertions.py`として保存し、`python test_assertions.py`で実行してください。

### コマンドラインからのテスト実行

ディレクトリ内のすべてのテストを検出して実行することができます：

```
python -m unittest discover
```

または特定のテストモジュールを実行：

```
python -m unittest test_calculation
```

あるいは特定のテストケースやテストメソッドを実行：

```
python -m unittest test_calculation.CalTest
python -m unittest test_calculation.CalTest.test_add_num_and_double
```

## まとめ

`unittest`フレームワークは以下を提供します：
- `TestCase`クラスによるテスト作成の構造化された方法
- テストの準備とクリーンアップのためのセットアップとティアダウンメソッド
- 様々な条件を検証するための各種アサーションメソッド
- テストスキップ機能
- テスト実行のためのコマンドラインオプション

開発ワークフローにテストを取り入れることで、コードが期待通りに動作することを確認し、開発プロセスの早い段階でバグを発見することができます。
