# コマンドライン引数

## 概要
コマンドライン引数はプログラム実行時に外部から値を渡す便利な方法で、スクリプトの柔軟性と再利用性を高めます。

## 主要概念
Pythonでは`sys.argv`リストを使用してコマンドライン引数にアクセスでき、インデックス0には常にスクリプト名自体が格納されます。

## 実践例

### 基本的なコマンドライン引数の使用法

以下のコードを`args_demo.py`という名前で保存してみましょう：

```python
# sys モジュールをインポート
import sys

# コマンドライン引数を出力
print("コマンドライン引数の一覧:", sys.argv)

# 引数の数を表示
print("引数の数:", len(sys.argv))

# 個別の引数にアクセス
print("スクリプト名:", sys.argv[0])  # インデックス0は常にスクリプト名

# 追加の引数がある場合は表示
if len(sys.argv) > 1:
    print("最初の引数:", sys.argv[1])
    
if len(sys.argv) > 2:
    print("2番目の引数:", sys.argv[2])
```

このコードを入力して実行してみましょう：

```
python args_demo.py arg1 arg2
```

実行結果：
```
コマンドライン引数の一覧: ['args_demo.py', 'arg1', 'arg2']
引数の数: 3
スクリプト名: args_demo.py
最初の引数: arg1
2番目の引数: arg2
```

### 実用的な例：計算機アプリケーション

次のコードを`calculator.py`という名前で保存しましょう：

```python
import sys

# コマンドライン引数の数をチェック
if len(sys.argv) != 4:
    print("使用法: python calculator.py [数値1] [演算子(+,-,*,/)] [数値2]")
    sys.exit(1)  # エラーコード1で終了

# 引数を取得
script_name = sys.argv[0]
num1 = float(sys.argv[1])  # 文字列から数値に変換
operator = sys.argv[2]
num2 = float(sys.argv[3])  # 文字列から数値に変換

# 演算子に基づいて計算を実行
result = None
if operator == "+":
    result = num1 + num2
elif operator == "-":
    result = num1 - num2
elif operator == "*":
    result = num1 * num2
elif operator == "/":
    # ゼロ除算を防ぐ
    if num2 == 0:
        print("エラー: ゼロで割ることはできません")
        sys.exit(1)
    result = num1 / num2
else:
    print(f"エラー: 対応していない演算子です: {operator}")
    sys.exit(1)

# 結果を表示
print(f"{num1} {operator} {num2} = {result}")
```

このコードを入力して実行してみましょう：

```
python calculator.py 10 + 5
```

実行結果：
```
10.0 + 5.0 = 15.0
```

別の演算も試してみましょう：

```
python calculator.py 20 * 3
```

実行結果：
```
20.0 * 3.0 = 60.0
```

無効な引数で実行すると：

```
python calculator.py 10
```

実行結果：
```
使用法: python calculator.py [数値1] [演算子(+,-,*,/)] [数値2]
```

### 発展例：ファイル処理

次のコードを`file_processor.py`という名前で保存しましょう：

```python
import sys

# コマンドライン引数の数をチェック
if len(sys.argv) != 3:
    print("使用法: python file_processor.py [入力ファイル] [出力ファイル]")
    sys.exit(1)

# 引数を取得
input_file = sys.argv[1]
output_file = sys.argv[2]

try:
    # 入力ファイルを読み込む
    with open(input_file, 'r', encoding='utf-8') as f_in:
        content = f_in.read()
        
    # 内容を変換（例：すべて大文字に）
    processed_content = content.upper()
    
    # 処理した内容を出力ファイルに書き込む
    with open(output_file, 'w', encoding='utf-8') as f_out:
        f_out.write(processed_content)
        
    print(f"処理完了: {input_file} を読み込み、{output_file} に保存しました。")
    
except FileNotFoundError:
    print(f"エラー: ファイル '{input_file}' が見つかりません。")
    sys.exit(1)
except Exception as e:
    print(f"エラーが発生しました: {e}")
    sys.exit(1)
```

このコードを使用するには、まず入力用テキストファイル`input.txt`を作成し、テキストを入力してください。

そして、以下のコマンドで実行してみましょう：

```
python file_processor.py input.txt output.txt
```

実行結果：
```
処理完了: input.txt を読み込み、output.txt に保存しました。
```

`output.txt`を開くと、`input.txt`の内容がすべて大文字に変換されていることが確認できます。
