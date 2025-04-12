# Pythonのpytestテスト入門（高度な機能含む）

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

または、`uv`を使用する場合：

```bash
uv pip install pytest
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

次に、実際のコードに対するテストを書いてみましょう。

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
        
    def save(self, dir_path, file_name):
        """
        指定されたディレクトリにファイルを保存する関数
        ディレクトリが存在しない場合は作成する
        """
        if not os.path.exists(dir_path):
            os.mkdir(dir_path)
        
        file_path = os.path.join(dir_path, file_name)
        with open(file_path, 'w') as f:
            f.write('test')
```

### 基本的なテストコード

以下のコードを`test_calculation.py`として保存してください：

```python
# test_calculation.py
import calculation
import pytest

class TestCal():
    def test_add_num_and_double(self):
        cal = calculation.Cal()
        assert cal.add_num_and_double(1, 1) == 4
        
    def test_add_num_and_double_raise(self):
        with pytest.raises(ValueError):
            cal = calculation.Cal()
            cal.add_num_and_double('1', '1')
```

以下のコマンドで実行してみましょう：

```bash
pytest test_calculation.py -v
```

実行結果：

```
===================== test session starts =====================
collected 2 items

test_calculation.py::TestCal::test_add_num_and_double PASSED
test_calculation.py::TestCal::test_add_num_and_double_raise PASSED

===================== 2 passed in 0.01s ======================
```

## テストフィクスチャの活用

テストフィクスチャは、テストの前処理や後処理を効率的に行うための仕組みです。

### クラスレベルのフィクスチャ

以下のコードを`test_fixture.py`として保存してください：

```python
# test_fixture.py
import os
import pytest
import calculation

class TestCal:
    @classmethod
    def setup_class(cls):
        print('start')
        cls.cal = calculation.Cal()
        cls.test_file_name = 'test.txt'
        
    @classmethod
    def teardown_class(cls):
        print('end')
        del cls.cal
        
    def test_add_num_and_double(self):
        assert self.cal.add_num_and_double(1, 1) == 4
        
    def test_add_num_and_double_raise(self):
        with pytest.raises(ValueError):
            self.cal.add_num_and_double('1', '1')
```

以下のコマンドで実行してみましょう：

```bash
pytest test_fixture.py -v -s
```

`-s`オプションを付けることで、print文の出力が表示されます。

実行結果：

```
===================== test session starts =====================
collected 2 items

test_fixture.py::TestCal::test_add_num_and_double start
PASSED
test_fixture.py::TestCal::test_add_num_and_double_raise PASSED
end

===================== 2 passed in 0.01s ======================
```

### メソッドレベルのフィクスチャ

各テストメソッド実行前後に処理を行いたい場合は、`setup_method`と`teardown_method`を使用します：

```python
# test_fixture_method.py
import pytest
import calculation

class TestCal:
    def setup_method(self, method):
        print(f'method= {method.__name__}')
        # self.cal = calculation.Cal()
        
    def teardown_method(self, method):
        print(f'method= {method.__name__}')
        # del self.cal
        
    def test_add_num_and_double(self):
        cal = calculation.Cal()
        assert cal.add_num_and_double(1, 1) == 4
        
    def test_add_num_and_double_raise(self):
        with pytest.raises(ValueError):
            cal = calculation.Cal()
            cal.add_num_and_double('1', '1')
```

## pytestフィクスチャを使ったより洗練された方法

pytestの`@pytest.fixture`デコレータを使うとより柔軟なフィクスチャ管理が可能です。

```python
# test_fixture_pytest.py
import os
import pytest
import calculation

@pytest.fixture
def cal():
    """テスト用のCalクラスのインスタンスを準備する"""
    print("fixture: Calクラスのインスタンスを準備します")
    cal_instance = calculation.Cal()
    yield cal_instance
    print("fixture: テスト完了後の後処理を行います")

def test_add_num_and_double_using_fixture(cal):
    """フィクスチャを使用したテスト"""
    assert cal.add_num_and_double(1, 1) == 4
    
def test_add_num_and_double_with_negative_using_fixture(cal):
    """フィクスチャを使用した負の数値のテスト"""
    assert cal.add_num_and_double(-1, 5) == 8
```

## ファイル操作のテスト

一時ディレクトリを使ったファイル操作のテストを行います。

```python
# test_file_operations.py
import os
import shutil
import pytest
import calculation

class TestCal:
    @classmethod
    def setup_class(cls):
        print('start')
        cls.cal = calculation.Cal()
        cls.test_dir = '/tmp/test_dir'
        cls.test_file_name = 'test.txt'
        
    @classmethod
    def teardown_class(cls):
        print('end')
        if os.path.exists(cls.test_dir):
            shutil.rmtree(cls.test_dir)
    
    def test_save_no_dir(self):
        self.cal.save(self.test_dir, self.test_file_name)
        test_file_path = os.path.join(
            self.test_dir, self.test_file_name
        )
        assert os.path.exists(test_file_path) is True
```

## ファイル作成用のフィクスチャ

`conftest.py`を使って共有フィクスチャを定義できます：

```python
# conftest.py
import os
import pytest

@pytest.fixture
def csv_file():
    """単純なCSVファイルパスを返すフィクスチャ"""
    return 'csv file!'

@pytest.fixture
def csv_file(tmpdir):
    """テスト用のCSVファイルを作成するフィクスチャ"""
    with open(os.path.join(tmpdir, 'test.csv'), 'w+') as c:
        print('before test')
        yield c
        print('after test')

def pytest_addoption(parser):
    """コマンドラインオプションを追加する"""
    parser.addoption('--os-name', default='linux', help='os name')
```

## tmpdir/tmp_pathフィクスチャの利用

pytestの`tmpdir`フィクスチャを使用して一時ディレクトリでのテストを行います：

```python
# test_with_tmpdir.py
import os
import pytest
import calculation

def test_save(tmpdir):
    """一時ディレクトリを使ったsaveメソッドのテスト"""
    cal = calculation.Cal()
    test_file_name = 'test.txt'
    cal.save(tmpdir, test_file_name)
    test_file_path = os.path.join(tmpdir, test_file_name)
    assert os.path.exists(test_file_path) is True
```

## コマンドラインオプションの利用

pytestはコマンドラインオプションを使用して、テスト実行時に特定の動作を変更できます：

```python
# test_with_options.py
import pytest
import calculation

def test_add_num_and_double(request):
    """コマンドラインオプションを使ったテスト"""
    os_name = request.config.getoption('--os-name')
    print(os_name)
    if os_name == 'mac':
        print('ls')
    elif os_name == 'windows':
        print('dir')
    cal = calculation.Cal()
    assert cal.add_num_and_double(1, 1) == 4
```

実行コマンド：

```bash
pytest test_with_options.py -v --os-name=mac
```

## テストのスキップとマーキング

特定の条件でテストをスキップしたり、マークを付けたりできます：

```python
# test_skip.py
import pytest
import calculation

is_release = True

class TestCal:
    @pytest.mark.skip(reason='skip!')
    def test_add_num_and_double(self):
        """常にスキップされるテスト"""
        cal = calculation.Cal()
        assert cal.add_num_and_double(1, 1) == 4
        
    @pytest.mark.skipif(is_release == True, reason='skip!')
    def test_add_num_and_double_raise(self):
        """条件付きでスキップされるテスト"""
        with pytest.raises(ValueError):
            cal = calculation.Cal()
            cal.add_num_and_double('1', '1')
```

## カバレッジの測定

テストカバレッジを測定するには、`pytest-cov`プラグインを使用します：

```bash
pip install pytest-cov
```

または、`uv`を使用する場合：

```bash
uv pip install pytest-cov
```

カバレッジレポートを生成するコマンド：

```bash
pytest --cov=calculation --cov-report term-missing
```

単発コマンドで実行する場合：

```bash
uvx --with pytest-cov pytest --cov=calculation --cov-report term-missing
```

実行結果：

```
---------- coverage: platform linux, python 3.10.4-final-0 -----------
Name             Stmts   Miss  Cover   Missing
----------------------------------------------
calculation.py      12      0   100%
----------------------------------------------
TOTAL              12      0   100%
```

## 並列実行

`pytest-xdist`プラグインを使用すると、テストを並列実行できます：

```bash
pip install pytest-xdist
```

または、`uv`を使用する場合：

```bash
uv pip install pytest-xdist
```

並列実行のコマンド：

```bash
pytest -n 4  # 4つのプロセスで並列実行
```

カバレッジと並列実行を組み合わせる：

```bash
uvx --with pytest-cov pytest-xdist pytest -n 4 --cov=calculation --cov-report term-missing
```

## パラメータ化されたテスト

同じテストを異なる入力値で実行するためのパラメータ化：

```python
# test_parametrize.py
import pytest
import calculation

@pytest.mark.parametrize("input_x, input_y, expected", [
    (1, 1, 4),
    (2, 3, 10),
    (0, 5, 10),
    (-1, 1, 0)
])
def test_add_num_and_double_parametrized(input_x, input_y, expected):
    """様々な入力値でのテスト"""
    cal = calculation.Cal()
    assert cal.add_num_and_double(input_x, input_y) == expected
```

## まとめ

pytestは直感的な構文とパワフルな機能を提供するPythonのテストフレームワークです。基本的なテスト関数からフィクスチャ、パラメータ化テスト、テストスキップ、カバレッジ測定まで、様々な機能を活用して効率的なテスト環境を構築できます。実際のプロジェクトではこれらの機能を組み合わせることで、より堅牢なテスト環境を実現できます。
