# importとmodule

## 概要
Pythonのimportとmoduleはコードを再利用可能な部品に分割し、大規模なプログラムを効率的に開発するための重要な機能です。

## 主要概念
moduleはPythonのコードが書かれたファイル、パッケージは複数のmoduleを含むディレクトリであり、importはこれらを現在の名前空間に読み込むための仕組みです。

## 実践的なステップ

### 1. パッケージ構造の作成

まず、以下のようなディレクトリ構造を作成します：

```
lesson_package/
├── __init__.py
├── utils.py
├── talk/
│   ├── __init__.py
│   ├── human.py
│   └── animal.py
└── tools/
    ├── __init__.py
    └── utils.py
```

このコードを入力して実行してみましょう（ディレクトリとファイルの作成）:

```python
# 必要なディレクトリを作成
import os

# lesson_packageディレクトリの作成
os.makedirs('lesson_package/talk', exist_ok=True)
os.makedirs('lesson_package/tools', exist_ok=True)

# 各__init__.pyファイルの作成
open('lesson_package/__init__.py', 'w').close()
open('lesson_package/talk/__init__.py', 'w').close()
open('lesson_package/tools/__init__.py', 'w').close()
```

これでパッケージ構造の基本が作成されました。次に各ファイルにコードを書きます。

### 2. utils.pyの作成

このコードを入力して実行してみましょう：

```python
# lesson_package/utils.pyを作成
with open('lesson_package/utils.py', 'w') as f:
    f.write("""def say_twice(word):
    # 受け取った単語に「!」を付けて2回繰り返す
    return (word + '!') * 2
""")

# lesson_package/tools/utils.pyも同じ内容で作成
with open('lesson_package/tools/utils.py', 'w') as f:
    f.write("""def say_twice(word):
    # 受け取った単語に「!」を付けて2回繰り返す
    return (word + '!') * 2
""")
```

### 3. talk下のファイル作成

このコードを入力して実行してみましょう：

```python
# human.pyの作成
with open('lesson_package/talk/human.py', 'w') as f:
    f.write("""def sing():
    return 'sing'


def cry():
    return 'cry'
""")

# animal.pyの作成
with open('lesson_package/talk/animal.py', 'w') as f:
    f.write("""def sing():
    return 'roar'


def cry():
    return 'howl'
""")
```

### 4. importの基本的な使い方

このコードを入力して実行してみましょう：

```python
# 方法1: パッケージ名を含めたフルパスでimport
import lesson_package.utils

# フルパスで関数を呼び出す
result = lesson_package.utils.say_twice('hello')
print(result)  # 出力: hello!hello!
```

実行結果：
```
hello!hello!
```

上記のコードでは、`lesson_package.utils`モジュール全体をインポートし、完全修飾名でモジュール内の関数を呼び出しています。

### 5. fromを使ったimport

このコードを入力して実行してみましょう：

```python
# 方法2: fromを使ってモジュールをインポート
from lesson_package import utils

# モジュール名だけで関数を呼び出せる
result = utils.say_twice('hello')
print(result)  # 出力: hello!hello!
```

実行結果：
```
hello!hello!
```

この方法では、`utils`モジュールだけをインポートするので、呼び出しが少し短くなります。

### 6. 関数を直接importする方法

このコードを入力して実行してみましょう：

```python
# 方法3: 関数を直接インポート（あまり推奨されない）
from lesson_package.utils import say_twice

# 関数名だけで直接呼び出せる
result = say_twice('hello')
print(result)  # 出力: hello!hello!
```

実行結果：
```
hello!hello!
```

この方法はコードが短くなりますが、関数がどこから来たのかわかりにくくなるため、大規模プロジェクトでは混乱を招く可能性があります。

### 7. エイリアスを使ったimport

このコードを入力して実行してみましょう：

```python
# 方法4: エイリアス（別名）を付けてimport
from lesson_package import utils as u

# 短い別名で呼び出せる
result = u.say_twice('hello')
print(result)  # 出力: hello!hello!
```

実行結果：
```
hello!hello!
```

エイリアスは特に名前が長いモジュールで便利ですが、短すぎる名前を使うとコードの可読性が下がることがあります。

### 8. サブパッケージのimport

このコードを入力して実行してみましょう：

```python
# サブパッケージ内のモジュールをインポート
from lesson_package import utils
from lesson_package.talk import human

print(human.sing())  # 出力: sing
```

実行結果：
```
sing
```

### 9. 複数のモジュールをimport

このコードを入力して実行してみましょう：

```python
# 同じパッケージから複数のモジュールをインポート
from lesson_package.talk import animal, human

print(human.sing())  # 出力: sing
print(animal.sing())  # 出力: roar
```

実行結果：
```
sing
roar
```

### 10. アスタリスク（*）を使ったimport

まず、`__init__.py`ファイルに`__all__`を設定します：

```python
# lesson_package/talk/__init__.pyを編集
with open('lesson_package/talk/__init__.py', 'w') as f:
    f.write("__all__ = ['animal', 'human']\n")
```

このコードを入力して実行してみましょう：

```python
# アスタリスクを使ったインポート（推奨されない）
from lesson_package.talk import *

print(animal.sing())  # 出力: roar
print(human.sing())   # 出力: sing
```

実行結果：
```
roar
sing
```

このやり方は名前空間が汚染される可能性があるため、一般的には推奨されません。

### 11. ImportErrorの処理

このコードを入力して実行してみましょう：

```python
# 存在しないモジュールをインポートする場合のエラー処理
try:
    from lesson_package.aaa import utils  # 存在しないモジュール
except ImportError:
    from lesson_package.tools import utils  # 代わりにこちらを使用

print(utils.say_twice('word'))  # 出力: word!word!
```

実行結果：
```
word!word!
```

このように例外処理を使うことで、モジュールが存在しない場合に代替のモジュールを使うことができます。

## まとめ

Pythonのimportとmoduleはコードを整理し、再利用するための強力な仕組みです。適切な使い方を身につけることで、保守性の高いPythonプログラムを開発することができます。最も推奨されるのは、明示的なインポート（方法1と方法2）で、どのモジュールから何をインポートしているかが明確にわかるようにすることです。
