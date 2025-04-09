# Python subprocessモジュール

## 概要
subprocessモジュールはPythonから外部コマンドを実行するための強力なツールで、OSコマンドをより安全かつ柔軟に扱うことができます。

## 基本概念
subprocessモジュールは、新しいプロセスの生成、標準入出力の制御、終了ステータスの取得を一貫したインターフェースで提供します。

## 実践的なコード例

### 基本的な使い方

まずは、基本的なsubprocessの使い方を見てみましょう。以下のコードを入力して実行してみましょう。

```python
import os
import subprocess

# os.system() - 従来の方法（非推奨）
print("=== os.system() の例 ===")
os.system('ls')
print("\n")

# subprocess.run() - 推奨される方法
print("=== subprocess.run() の例 ===")
result = subprocess.run(['ls', '-l'])
print(f"終了コード: {result.returncode}")
```

**実行結果の解説**:
- `os.system()`はシンプルですが、出力の取得や詳細な制御が難しいため非推奨です
- `subprocess.run()`はコマンドをリスト形式で受け取り、実行します
- `result.returncode`で終了コードを確認できます（0は正常終了）

### シェルコマンドとパイプの使用

次に、シェルコマンドやパイプを使用する方法を見てみましょう。

```python
import subprocess

# shell=True でシェルコマンドを実行する方法
print("=== シェルコマンドを使用した例 ===")
subprocess.run('ls -al | grep "py"', shell=True)
print("\n")

# 注意: shell=True はセキュリティリスクがあります
# 特にユーザー入力を含む場合は使用を避けるべきです
```

**実行結果の解説**:
- `shell=True`を指定するとシェル経由でコマンドを実行します
- これにより、パイプ（`|`）などのシェル機能が使用可能になります
- ただし、セキュリティ上のリスクがあるため、特にユーザー入力を含む場合は避けるべきです

### エラーハンドリング

コマンド実行時のエラーハンドリングの方法を見てみましょう。

```python
import subprocess

# 存在しないコマンドを実行
print("=== エラーハンドリングの例 ===")

# エラーを確認する方法
try:
    result = subprocess.run('non_existent_command', shell=True)
    print(f"終了コード: {result.returncode}")  # エラーの場合は0以外の値
except Exception as e:
    print(f"例外が発生しました: {e}")
print("\n")

# check=True を使用すると、エラー時に例外が発生します
try:
    result = subprocess.run('non_existent_command', shell=True, check=True)
except subprocess.CalledProcessError as e:
    print(f"コマンドがエラーで終了しました: {e}")
```

**実行結果の解説**:
- 存在しないコマンドを実行すると、デフォルトでは例外は発生せず、終了コードが0以外になります
- `check=True`を指定すると、コマンドがエラーで終了した場合に`CalledProcessError`例外が発生します
- これにより、エラー処理をより明示的に行えます

### シェルを使わずにパイプを実装する

最後に、セキュリティを考慮してシェルを使わずにパイプを実装する方法を見てみましょう。

```python
import subprocess

print("=== シェルを使わないパイプの実装 ===")

# 第1コマンド: ls -al
p1 = subprocess.Popen(['ls', '-al'], stdout=subprocess.PIPE)

# 第2コマンド: grep py
p2 = subprocess.Popen(['grep', 'py'], stdin=p1.stdout, stdout=subprocess.PIPE)

# p1の標準出力をクローズして、p2に対するEOFシグナルを送信できるようにする
p1.stdout.close()

# 出力を取得
output = p2.communicate()[0]
print("コマンド出力:")
print(output.decode())

print(f"終了コード: {p2.returncode}")
```

**実行結果の解説**:
- `subprocess.Popen`を使用して、個別のプロセスを作成します
- `stdout=subprocess.PIPE`で標準出力をパイプとして取得します
- `p1.stdout`を`p2`の標準入力として渡すことで、パイプラインを作成します
- `p1.stdout.close()`は重要で、これにより`p1`が終了したとき`p2`に対してEOFシグナルが送信されます
- `p2.communicate()`で実際に処理を実行し、結果を取得します

## まとめ

subprocessモジュールは外部コマンドを実行するための強力なツールです。主なポイントとしては：

1. 基本的には`subprocess.run()`を使用する
2. セキュリティリスクを避けるため、可能な限り`shell=True`は使用しない
3. エラーハンドリングには`check=True`と例外処理を活用する
4. 複雑なパイプライン処理では`subprocess.Popen`を使用する

これらの知識を活用して、Pythonから外部コマンドを安全かつ効果的に実行しましょう。
