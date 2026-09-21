# Pythonの`__name__`と`__main__`の使い方

## 概要
`__name__`変数はPythonモジュールのインポート制御に役立ち、コードの再利用性を高める重要な機能です。

## 主要概念
`__name__`はモジュールが直接実行されると`"__main__"`になり、インポートされると実際のモジュール名になります。

## 実際に試せるコード例（Step by Step）

### ステップ1: 基本的な `__name__` の動作を確認する

まず、`config.py` という名前のファイルを作成し、以下のコードを記述してください:

```python
# ファイル名: config.py
print(f'config: {__name__}')
```

次に、`main.py` という名前のファイルを作成し、以下のコードを記述してください:

```python
# ファイル名: main.py
# config.py をインポートする
import config

# 現在のモジュールの __name__ を表示する
print(f'main: {__name__}')
```

このコードを入力して、`main.py` を実行してみましょう:

```
python main.py
```

**期待される出力:**
```
config: config
main: __main__
```

**解説:**
- `config.py` がインポートされると、その中のコードが実行され `config: config` と表示されます
- `main.py` は直接実行しているので、`__name__` の値が `"__main__"` となります

### ステップ2: `if __name__ == '__main__'` を使ってコードの実行を制御する

`config.py` を以下のように修正してください:

```python
# ファイル名: config.py
def main():
    print(f'config: {__name__}')

# このモジュールが直接実行された場合のみ main() 関数を実行する
if __name__ == '__main__':
    main()
else:
    print(f'config モジュールがインポートされました。__name__ の値: {__name__}')
```

次に、`main.py` は以下のようにします:

```python
# ファイル名: main.py
# config.py をインポートする
import config

# 現在のモジュールの __name__ を表示する
print(f'main: {__name__}')
```

このコードを入力して、まず `main.py` を実行してみましょう:

```
python main.py
```

**期待される出力:**
```
config モジュールがインポートされました。__name__ の値: config
main: __main__
```

次に、`config.py` を直接実行してみましょう:

```
python config.py
```

**期待される出力:**
```
config: __main__
```

**解説:**
- `main.py` から `config.py` をインポートすると、`__name__` は `"config"` となるため、`if __name__ == '__main__'` ブロック内のコードは実行されません
- `config.py` を直接実行すると、`__name__` は `"__main__"` となるため、`main()` 関数が実行されます

### ステップ3: 実用的な例 - 再利用可能なモジュールの作成

`utils.py` という名前の実用的なモジュールを作成してみましょう:

```python
# ファイル名: utils.py
def calculate_sum(numbers):
    """リスト内の数値の合計を計算する関数"""
    return sum(numbers)

def calculate_average(numbers):
    """リスト内の数値の平均を計算する関数"""
    if not numbers:
        return 0
    return sum(numbers) / len(numbers)

# テストコード
if __name__ == '__main__':
    # このモジュールが直接実行された場合のみテストを実行
    test_data = [1, 2, 3, 4, 5]
    print(f"テストデータ: {test_data}")
    print(f"合計: {calculate_sum(test_data)}")
    print(f"平均: {calculate_average(test_data)}")
    print("テスト完了!")
```

`app.py` という名前のファイルを作成し、`utils.py` を使用してみましょう:

```python
# ファイル名: app.py
# utils モジュールをインポート
import utils

# 実際のアプリケーションコード
data = [10, 20, 30, 40, 50]
total = utils.calculate_sum(data)
average = utils.calculate_average(data)

print(f"アプリケーションデータ: {data}")
print(f"合計: {total}")
print(f"平均: {average}")
```

まず、`utils.py` を直接実行してテストしてみましょう:

```
python utils.py
```

**期待される出力:**
```
テストデータ: [1, 2, 3, 4, 5]
合計: 15
平均: 3.0
テスト完了!
```

次に、`app.py` を実行してみましょう:

```
python app.py
```

**期待される出力:**
```
アプリケーションデータ: [10, 20, 30, 40, 50]
合計: 150
平均: 30.0
```

**解説:**
- `utils.py` を直接実行すると、テストコードが実行されます
- `app.py` から `utils.py` をインポートすると、テストコードは実行されず、必要な関数のみが使用できます
- これにより、同じコードを再利用可能なモジュールとしても、独立したスクリプトとしても使用できます

## まとめ

Pythonの`__name__`変数と`if __name__ == '__main__'`の使い方を理解することで:

1. モジュールを作成する際に、インポート時と直接実行時の動作を適切に制御できます
2. テストコードを含むモジュールを他のプログラムから安全に再利用できます
3. 一つのファイルを独立したスクリプトとしても、インポート可能なモジュールとしても使用できます
