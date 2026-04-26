# Pythonにおけるモック（Mock）の使い方

## 概要
ユニットテストにおいて外部依存を分離するためのモック（Mock）は、テストの信頼性と実行速度を向上させる重要な技術です。

## モックとは
モックとは、実際のオブジェクトや関数の振る舞いをシミュレートするオブジェクトで、テスト対象コードを依存関係から分離することができます。

## 基本的なモックの使い方

### 1. モックのインポート

```python
import unittest
from unittest.mock import Mock

# テストするクラス
def test_basic_mock():
    # モックオブジェクトを作成
    mock_obj = Mock()
    
    # モックにメソッドを呼び出す
    mock_obj.some_method()
    
    # メソッドが呼び出されたことを検証
    mock_obj.some_method.assert_called()
    
    print("基本的なモックのテストが成功しました！")

# 実行
test_basic_mock()
```

このコードを入力して実行してみましょう。モックオブジェクトを作成し、メソッドが呼び出されたかどうかを検証しています。実行結果に「基本的なモックのテストが成功しました！」と表示されれば成功です。

### 2. return_valueの設定

```python
from unittest.mock import Mock

def test_return_value():
    # 戻り値を設定したモックを作成
    mock_obj = Mock(return_value=42)
    
    # 呼び出すと設定した戻り値が返される
    result = mock_obj()
    
    # 検証
    assert result == 42
    print(f"戻り値のテスト成功: {result} == 42")
    
    # メソッドごとに戻り値を設定
    mock_obj.calculate = Mock(return_value=100)
    calc_result = mock_obj.calculate()
    
    assert calc_result == 100
    print(f"メソッドの戻り値テスト成功: {calc_result} == 100")

# 実行
test_return_value()
```

このコードを実行してみましょう。モックオブジェクト自体やそのメソッドに戻り値を設定する方法を示しています。「戻り値のテスト成功: 42 == 42」と「メソッドの戻り値テスト成功: 100 == 100」が表示されれば成功です。

### 3. MagicMockを使ったテスト

```python
from unittest.mock import MagicMock

def test_magic_mock():
    # MagicMockはMockの拡張版で、多くの魔法メソッドが事前に定義されている
    magic_mock = MagicMock()
    
    # 例えば、__str__などのメソッドがあらかじめ実装されている
    print(f"MagicMockの文字列表現: {str(magic_mock)}")
    
    # 戻り値の設定
    magic_mock.calculate.return_value = 100
    result = magic_mock.calculate()
    
    # 検証
    assert result == 100
    magic_mock.calculate.assert_called_once()
    print("MagicMockのテスト成功！")

# 実行
test_magic_mock()
```

このコードを実行してみましょう。MagicMockは標準のMockよりも便利なメソッドが最初から実装されており、より柔軟にモックの振る舞いを設定できます。「MagicMockのテスト成功！」が表示されれば成功です。

### 4. 実際のクラスのメソッドをモック化

```python
from unittest.mock import patch

# テスト対象のクラス
class Salary:
    def __init__(self, base=100, year=2025):
        self.base = base
        self.year = year
        
    def bonus_price(self, year):
        # この部分は外部APIを呼び出すと仮定
        # 実際のテストでは呼び出したくない
        return 1  # APIから返されると仮定する値
        
    def calculation_salary(self):
        bonus = 0
        if self.year < 2030:
            bonus = self.bonus_price(year=self.year)
        return self.base + bonus

# テスト関数
def test_calculation_salary():
    # Salaryクラスのbonus_priceメソッドをパッチ
    with patch('__main__.Salary.bonus_price') as mock_bonus:
        # モックの戻り値を設定
        mock_bonus.return_value = 5
        
        # テスト対象のインスタンスを作成
        salary = Salary(base=100, year=2025)
        
        # 計算を実行
        result = salary.calculation_salary()
        
        # 検証
        assert result == 105
        mock_bonus.assert_called_once_with(year=2025)
        print(f"計算結果: {result}, モックは呼び出されました")

# 実行
test_calculation_salary()
```

このコードを実行してみましょう。`patch`を使って特定のメソッドだけをモック化する方法を示しています。実際にAPIを呼び出すことなく、`bonus_price`メソッドの戻り値を制御してテストできています。「計算結果: 105, モックは呼び出されました」が表示されれば成功です。

### 5. side_effectを使った高度な振る舞いの設定

```python
from unittest.mock import Mock

def test_side_effect():
    # 関数をside_effectとして設定
    def side_effect_func(arg):
        if arg > 10:
            return arg * 2
        else:
            return arg
    
    # モックにside_effectを設定
    mock_obj = Mock()
    mock_obj.calculate.side_effect = side_effect_func
    
    # 呼び出し
    result1 = mock_obj.calculate(5)
    result2 = mock_obj.calculate(20)
    
    # 検証
    assert result1 == 5
    assert result2 == 40
    print(f"Side Effect テスト成功: {result1} == 5, {result2} == 40")
    
    # 例外をraiseするside_effect
    mock_obj.risky_operation.side_effect = ValueError("エラーが発生しました")
    
    try:
        mock_obj.risky_operation()
        print("この行は実行されないはずです")
    except ValueError as e:
        print(f"期待通りの例外が発生しました: {e}")

# 実行
test_side_effect()
```

このコードを実行してみましょう。`side_effect`を使うと、単純な戻り値だけでなく、引数に応じた動的な振る舞いや例外の発生などを設定できます。「Side Effect テスト成功: 5 == 5, 40 == 40」と「期待通りの例外が発生しました: エラーが発生しました」が表示されれば成功です。

### 6. mock.patchを使った依存関係の置き換え

```python
import unittest
from unittest.mock import patch

# 外部APIを呼び出すクラス
class ThirdPartyBonusRestApi:
    def bonus_price(self, year):
        # 実際のAPIを呼び出す（テスト時には呼び出したくない）
        # ここでは簡易的に実装
        return 1
    
    def get_api_name(self):
        return 'bonus'

# テスト対象のクラス
class Salary:
    def __init__(self, base=100, year=2025):
        self.base = base
        self.year = year
        self.bonus_api = ThirdPartyBonusRestApi()
        
    def calculation_salary(self):
        bonus = 0
        if self.year < 2030:
            bonus = self.bonus_api.bonus_price(year=self.year)
        return self.base + bonus

# テストクラス
class TestSalary(unittest.TestCase):
    
    def test_calculation_salary(self):
        # ThirdPartyBonusRestApiのbonus_priceメソッドをモック化
        with patch('__main__.ThirdPartyBonusRestApi.bonus_price', return_value=10):
            # テスト対象のインスタンスを作成
            salary = Salary(base=100, year=2025)
            
            # 計算を実行
            result = salary.calculation_salary()
            
            # 検証
            self.assertEqual(result, 110)
            print(f"計算結果: {result} == 110")
    
    # クラス全体をモック化する例
    def test_calculation_with_mock_class(self):
        # モッククラスを作成
        mock_api = Mock()
        mock_api.bonus_price.return_value = 20
        mock_api.get_api_name.return_value = 'mock_bonus'
        
        # ThirdPartyBonusRestApiクラス全体をパッチ
        with patch('__main__.ThirdPartyBonusRestApi', return_value=mock_api):
            salary = Salary(base=100, year=2025)
            result = salary.calculation_salary()
            
            # 検証
            self.assertEqual(result, 120)
            mock_api.bonus_price.assert_called_once_with(year=2025)
            print(f"モッククラステスト成功: {result} == 120")

# テストを実行
if __name__ == '__main__':
    unittest.main()
```

このコードは、`unittest`フレームワークを使ったより実践的なテスト例です。`patch`デコレータや`with patch`文を使って、外部APIを呼び出すクラスをモック化しています。コマンドラインからテストを実行するか、上記のコード全体を実行してください。テストが成功すれば、計算結果と検証メッセージが表示されます。

### 7. セットアップとティアダウンを使ったテスト

```python
import unittest
from unittest.mock import patch, Mock

class TestWithSetupTeardown(unittest.TestCase):
    def setUp(self):
        # テスト前の準備
        self.patcher = patch('__main__.ThirdPartyBonusRestApi.bonus_price')
        self.mock_bonus = self.patcher.start()
        self.mock_bonus.return_value = 15
        
        # テスト対象のインスタンスを作成
        self.salary = Salary(base=100, year=2025)
    
    def tearDown(self):
        # テスト後のクリーンアップ
        self.patcher.stop()
    
    def test_calculation_salary(self):
        # 計算を実行
        result = self.salary.calculation_salary()
        
        # 検証
        self.assertEqual(result, 115)
        self.mock_bonus.assert_called_once_with(year=2025)
        print(f"setUp/tearDownテスト成功: {result} == 115")

# テストを実行
if __name__ == '__main__':
    unittest.main()
```

このコードでは、`setUp`と`tearDown`メソッドを使って、テストの前後でモックの設定と解除を行っています。こうすることで、複数のテストケースで同じモック設定を再利用できます。コマンドラインからテストを実行するか、上記のコード全体を実行してください。

## まとめ

Pythonのモック機能を使うことで、以下のようなメリットがあります：

1. 外部依存を分離し、純粋なユニットテストを実現
2. テストの実行速度の向上
3. テスト実行環境に依存しないテストの作成
4. 複雑なシナリオや例外ケースのテストが容易に

モックの基本的な使い方を理解し、実際のプロジェクトに適用してみましょう。テストの品質と開発効率の向上に役立ちます。
