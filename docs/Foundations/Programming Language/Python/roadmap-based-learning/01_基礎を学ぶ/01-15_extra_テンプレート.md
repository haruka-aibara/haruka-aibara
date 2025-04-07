# Pythonの文字列テンプレート（string.Template）

## 概要
文字列テンプレートは、文字列内の変数をプレースホルダー（$記号）で表現し、後から値を埋め込む便利な機能です。

## 主要概念
string.Templateクラスを使用すると、文字列内の$nameのような変数を指定した値で置換できます。

## 実践：文字列テンプレートの基本

### 例1：基本的なテンプレートの使い方

以下のコードを入力して実行してみましょう：

```python
# string モジュールをインポート
import string

# テンプレート文字列を作成（複数行の文字列には三重引用符を使用）
template_str = """\
Hi $name.

$contents

Have a good day
"""

# Template オブジェクトを作成
template = string.Template(template_str)

# 変数に値を代入してテンプレートを完成させる
message = template.substitute(name='Mike', contents='How are you?')

# 結果を表示
print(message)
```

**実行結果：**
```
Hi Mike.

How are you?

Have a good day
```

### 解説
1. `string` モジュールをインポートして、`Template` クラスにアクセスできるようにしています。
2. テンプレート文字列を作成し、置換したい箇所に `$name` や `$contents` のような変数名を記述しています。
3. `string.Template()` でテンプレートオブジェクトを作成します。
4. `substitute()` メソッドを使って、変数に実際の値を代入します。キーワード引数で `name='Mike'` のように指定します。
5. 完成した文字列が返され、それを表示しています。

### 注意点
- プレースホルダーには `$` 記号を使います。
- 変数名には英数字とアンダースコアのみ使用できます。
- `${name}` のように変数名を中括弧で囲むこともできます（変数名の境界を明確にしたい場合に便利）。
- `substitute()` メソッドは、テンプレート内の全ての変数に値が渡されない場合はエラーになります。全ての変数に値を渡す必要がないなら、代わりに `safe_substitute()` メソッドを使います。
