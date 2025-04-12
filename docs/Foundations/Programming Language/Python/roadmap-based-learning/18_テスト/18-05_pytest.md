# Pythonのpytestテスト入門

## 概要
pytestはPythonのテストフレームワークで、シンプルな構文とパワフルな機能によって、単体テストから統合テストまで効率的に行えます。

## 基本概念
pytestはテスト関数やテストクラスを自動的に検出し、アサーションを使って期待する結果との一致を検証します。

## 環境準備

### pytestのインストール

まずはpytestをインストールしましょう。以下のコマンドをターミナルで実行してください：

```bash
pip install pytest
```

## 基本的なテストの書き方

### シンプルなテスト関数

以下のコードを`test_simple.py`という名前で保存してください：

```python
# test_simple.py

def test_addition():
    """シンプルな足し算のテスト"""
    assert 1 + 1 == 2

def test_string():
    """文字列操作のテスト"""
    assert "hello" + " world" == "hello world"
```

以下のコマンドで実行してみましょう：

```bash
pytest test_simple.py -v
```

実行結果：

```
===================== test session starts =====================
collected 2 items

test_simple.py::test_addition PASSED
test_simple.py::test_string PASSED

===================== 2 passed in 0.01s ======================
```

上記の例では、`assert`文を使って期待される結果を検証しています。テスト関数は`test_`という接頭辞で始まり、pytestが自動的に検出します。

## 実際のコードをテストする

次に、実際のコードに対するテストを書いてみましょう。先のスクリーンショットに示されているコードを例に使用します。

### テスト対象のコード

以下のコードを`calculation.py`として保存してください：

```python
# calculation.py
class Cal():
    def add_num_and_double(self, x, y):
        """
        2つの数値を受け取り、足してから2倍にする関数
        数値以外が入力された場合はValueErrorを発生させる
        """
        if type(x) is not int or type(y) is not int:
            raise ValueError
        result = x + y
        result *= 2
        return result
```

### テストコード

次に、以下のコードを`test_calculation.py`として保存してください：

```python
# test_calculation.py
import pytest
from calculation import Cal

class TestCal:
    def test_add_num_and_double(self):
        """add_num_and_doubleメソッドの正常系テスト"""
        cal = Cal()
        # 1 + 1 = 2、それを2倍して4が返されるはず
        assert cal.add_num_and_double(1, 1) == 4
        
    def test_add_num_and_double_with_negative(self):
        """負の数値のテスト"""
        cal = Cal()
        assert cal.add_num_and_double(-1, 5) == 8
        
    def test_add_num_and_double_raise_error(self):
        """例外発生のテスト"""
        cal = Cal()
        with pytest.raises(ValueError):
            cal.add_num_and_double('1', '1')
```

以下のコマンドで実行してみましょう：

```bash
pytest test_calculation.py -v
```

実行結果：

```
===================== test session starts =====================
collected 3 items

test_calculation.py::TestCal::test_add_num_and_double PASSED
test_calculation.py::TestCal::test_add_num_and_double_with_negative PASSED
test_calculation.py::TestCal::test_add_num_and_double_raise_error PASSED

===================== 3 passed in 0.02s ======================
```

## テストフィクスチャの使用

テストフィクスチャを使うと、テスト実行前の準備やテスト後の後処理を効率的に行えます。

以下のコードを`test_fixture.py`として保存してください：

```python
# test_fixture.py
import pytest
from calculation import Cal

# フィクスチャの定義
@pytest.fixture
def calc():
    """テスト用のCalクラスのインスタンスを準備する"""
    print("fixture: Calクラスのインスタンスを準備します")
    cal = Cal()
    yield cal
    print("fixture: テスト完了後の後処理を行います")

def test_add_num_and_double_using_fixture(calc):
    """フィクスチャを使用したテスト"""
    assert calc.add_num_and_double(1, 1) == 4
    
def test_add_num_and_double_with_negative_using_fixture(calc):
    """フィクスチャを使用した負の数値のテスト"""
    assert calc.add_num_and_double(-1, 5) == 8
```

以下のコマンドで実行してみましょう：

```bash
pytest test_fixture.py -v
```

実行結果：

```
===================== test session starts =====================
collected 2 items

test_fixture.py::test_add_num_and_double_using_fixture PASSED
test_fixture.py::test_add_num_and_double_with_negative_using_fixture PASSED

===================== 2 passed in 0.02s ======================
```

出力を表示するには`-s`オプションを追加します：

```bash
pytest test_fixture.py -v -s
```

実行結果：

```
===================== test session starts =====================
collected 2 items

test_fixture.py::test_add_num_and_double_using_fixture fixture: Calクラスのインスタンスを準備します
PASSED
fixture: テスト完了後の後処理を行います
test_fixture.py::test_add_num_and_double_with_negative_using_fixture fixture: Calクラスのインスタンスを準備します
PASSED
fixture: テスト完了後の後処理を行います

===================== 2 passed in 0.02s ======================
```

## パラメータ化されたテスト

同じテストを複数の入力値で実行したい場合は、パラメータ化を利用できます。

以下のコードを`test_parametrize.py`として保存してください：

```python
# test_parametrize.py
import pytest
from calculation import Cal

@pytest.mark.parametrize("input_x, input_y, expected", [
    (1, 1, 4),
    (2, 3, 10),
    (0, 5, 10),
    (-1, 1, 0)
])
def test_add_num_and_double_parametrized(input_x, input_y, expected):
    """様々な入力値でのテスト"""
    cal = Cal()
    assert cal.add_num_and_double(input_x, input_y) == expected
```

以下のコマンドで実行してみましょう：

```bash
pytest test_parametrize.py -v
```

実行結果：

```
===================== test session starts =====================
collected 4 items

test_parametrize.py::test_add_num_and_double_parametrized[1-1-4] PASSED
test_parametrize.py::test_add_num_and_double_parametrized[2-3-10] PASSED
test_parametrize.py::test_add_num_and_double_parametrized[0-5-10] PASSED
test_parametrize.py::test_add_num_and_double_parametrized[-1-1-0] PASSED

===================== 4 passed in 0.02s ======================
```

## テストのマーキング

特定のテストにマークを付けることで、テストをグループ化したり、特定のテストだけを実行したりできます。

以下のコードを`test_marking.py`として保存してください：

```python
# test_marking.py
import pytest
from calculation import Cal

@pytest.mark.basic
def test_add_num_and_double_basic():
    """基本的なテスト"""
    cal = Cal()
    assert cal.add_num_and_double(1, 1) == 4

@pytest.mark.advanced
def test_add_num_and_double_advanced():
    """応用的なテスト"""
    cal = Cal()
    assert cal.add_num_and_double(10, 20) == 60
```

特定のマークが付いたテストだけを実行するには、以下のコマンドを使用します：

```bash
pytest test_marking.py -v -m basic
```

実行結果：

```
===================== test session starts =====================
collected 2 items / 1 deselected / 1 selected

test_marking.py::test_add_num_and_double_basic PASSED

===================== 1 passed, 1 deselected in 0.01s ======================
```

## まとめ

pytestは直感的な構文で効率的なテストを書くことができるPythonのテストフレームワークです。基本的なテスト関数の記述から、フィクスチャ、パラメータ化テスト、テストのマーキングなど、様々な機能を提供しています。実際のプロジェクトでは、これらの機能を組み合わせることで、より堅牢なテスト環境を構築できます。
