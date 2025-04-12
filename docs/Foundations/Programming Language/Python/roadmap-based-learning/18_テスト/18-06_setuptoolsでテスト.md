# Setuptoolsでテストを実装する方法

## 概要
Setuptoolsを使用したPythonパッケージのテスト自動化は、品質の高いコードを維持するために不可欠です。

## 主要概念
Setuptoolsは`setup.py`ファイルを通じて、テストの検出・実行・管理を一元化し、開発ワークフローを効率化します。

## ステップバイステップ実装ガイド

### 1. 基本的なプロジェクト構成を作る

まずは以下のような構成のプロジェクトを準備しましょう：

```
my_package/
│
├── my_package/
│   ├── __init__.py
│   └── calculator.py
│
├── tests/
│   ├── __init__.py
│   └── test_calculator.py
│
└── setup.py
```

### 2. テスト対象のモジュールを作成する

次に、テスト対象となる簡単な計算機能を実装します。

以下のコードを`my_package/calculator.py`に入力して実行してみましょう：

```python
# 簡単な計算機能を提供するモジュール

def add(a, b):
    """2つの数値を加算する"""
    return a + b

def subtract(a, b):
    """1つ目の数値から2つ目の数値を減算する"""
    return a - b

def multiply(a, b):
    """2つの数値を乗算する"""
    return a * b

def divide(a, b):
    """1つ目の数値を2つ目の数値で除算する"""
    if b == 0:
        raise ValueError("ゼロによる除算はできません")
    return a / b
```

このファイルはテスト対象のコードです。実行結果はありませんが、この関数をテストしていきます。

### 3. テストコードを作成する

続いて、テストコードを作成します。

以下のコードを`tests/test_calculator.py`に入力してみましょう：

```python
# calculatorモジュールのテスト

import unittest
from my_package.calculator import add, subtract, multiply, divide

class TestCalculator(unittest.TestCase):
    
    def test_add(self):
        """加算関数のテスト"""
        self.assertEqual(add(2, 3), 5)
        self.assertEqual(add(-1, 1), 0)
        self.assertEqual(add(-1, -1), -2)
    
    def test_subtract(self):
        """減算関数のテスト"""
        self.assertEqual(subtract(5, 3), 2)
        self.assertEqual(subtract(1, 5), -4)
        self.assertEqual(subtract(-1, -1), 0)
    
    def test_multiply(self):
        """乗算関数のテスト"""
        self.assertEqual(multiply(2, 3), 6)
        self.assertEqual(multiply(-1, 3), -3)
        self.assertEqual(multiply(-2, -2), 4)
    
    def test_divide(self):
        """除算関数のテスト"""
        self.assertEqual(divide(6, 3), 2)
        self.assertEqual(divide(5, 2), 2.5)
        self.assertEqual(divide(-6, 2), -3)
        
    def test_divide_by_zero(self):
        """ゼロ除算時の例外発生テスト"""
        with self.assertRaises(ValueError):
            divide(5, 0)

if __name__ == '__main__':
    unittest.main()
```

このテストコードを単独で実行するには、以下のコマンドを使います：

```
python -m tests.test_calculator
```

実行すると以下のような結果が表示されます：

```
.....
----------------------------------------------------------------------
Ran 5 tests in 0.001s

OK
```

これは5つのテストがすべて成功したことを示しています。

### 4. setup.pyでテスト実行の設定をする

次に、Setuptoolsを使ってテストを実行する設定を行います。

以下のコードを`setup.py`に入力してみましょう：

```python
from setuptools import setup, find_packages

setup(
    name="my_package",
    version="0.1",
    packages=find_packages(),
    
    # テスト関連の設定
    test_suite="tests",  # テストディレクトリを指定
    tests_require=[
        "pytest",        # 必要なテストツールを指定
    ],
)
```

### 5. Setuptoolsでテストを実行する

このSetupファイルを使ってテストを実行するには、以下のコマンドを入力してみましょう：

```
python setup.py test
```

実行すると以下のような結果が表示されます：

```
running test
running egg_info
writing my_package.egg-info/PKG-INFO
writing dependency_links to my_package.egg-info/dependency_links.txt
writing requirements to my_package.egg-info/requires.txt
writing top-level names to my_package.egg-info/top_level.txt
reading manifest file 'my_package.egg-info/SOURCES.txt'
writing manifest file 'my_package.egg-info/SOURCES.txt'
running build_ext
test_add (tests.test_calculator.TestCalculator) ... ok
test_divide (tests.test_calculator.TestCalculator) ... ok
test_divide_by_zero (tests.test_calculator.TestCalculator) ... ok
test_multiply (tests.test_calculator.TestCalculator) ... ok
test_subtract (tests.test_calculator.TestCalculator) ... ok

----------------------------------------------------------------------
Ran 5 tests in 0.001s

OK
```

これで、Setuptoolsを使ってプロジェクト全体のテストを一括実行できました。

### 6. pytest を使ったテスト実行の設定

多くのプロジェクトでは、unittest より pytest を使用することが一般的です。pytestを使うように設定してみましょう。

まず、pytestをインストールします:

```
pip install pytest pytest-runner
```

次に、`setup.py`を以下のように修正します:

```python
from setuptools import setup, find_packages

setup(
    name="my_package",
    version="0.1",
    packages=find_packages(),
    
    # テスト関連の設定
    tests_require=["pytest"],
    setup_requires=["pytest-runner"],
)
```

また、`setup.cfg`というファイルを作成し、pytest の設定を追加します:

```
[aliases]
test=pytest

[tool:pytest]
testpaths=tests
```

これで以下のコマンドでテストが実行できるようになります:

```
python setup.py test
```

実行結果の例:

```
running pytest
running egg_info
writing my_package.egg-info/PKG-INFO
writing dependency_links to my_package.egg-info/dependency_links.txt
writing top-level names to my_package.egg-info/top_level.txt
reading manifest file 'my_package.egg-info/SOURCES.txt'
writing manifest file 'my_package.egg-info/SOURCES.txt'
running build_ext
============================= test session starts ==============================
platform linux -- Python 3.9.7, pytest-7.3.1, pluggy-1.0.0
rootdir: /path/to/my_package
collected 5 items

tests/test_calculator.py .....                                           [100%]

============================== 5 passed in 0.03s ===============================
```
