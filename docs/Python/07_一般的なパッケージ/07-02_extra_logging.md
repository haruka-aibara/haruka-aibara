# Pythonロギング入門

## 概要
ロギングはプログラムの実行状況を記録する重要な機能で、デバッグやエラー追跡に不可欠です。

## 基本概念
Pythonの`logging`モジュールは、異なるレベル（DEBUG, INFO, WARNING, ERROR, CRITICAL）のログメッセージを管理する包括的なシステムを提供します。

## 基本的なロギングの使い方

### 1. シンプルなロギング

まずは基本的なロギングの例から始めましょう。以下のコードを入力して実行してみましょう：

```python
import logging

# ログの基本設定（DEBUG以上のレベルのログをファイルに出力）
logging.basicConfig(level=logging.DEBUG, filename="test.log")

# 各レベルのログを出力
logging.critical("critical")  # 最も重要度の高いレベル
logging.error("error")        # エラーメッセージ
logging.warning("warning")    # 警告メッセージ
logging.info("info")          # 情報メッセージ
logging.debug("debug")        # デバッグ情報（最も詳細）

# 変数の値を含むログメッセージの書き方
message = "テストメッセージ"
logging.debug(f"{message} aaa")  # f文字列を使用
logging.debug("info %s %s" % ("test", "test2"))  # %演算子を使用（非推奨）
logging.debug("info %s %s", "test", "test2")     # 推奨される方法
```

実行すると、`test.log`ファイルが作成され、以下のような内容が記録されます：

```
CRITICAL:root:critical
ERROR:root:error
WARNING:root:warning
INFO:root:info
DEBUG:root:debug
DEBUG:root:テストメッセージ aaa
DEBUG:root:info test test2
DEBUG:root:info test test2
```

**解説：**
- `logging.basicConfig`で基本設定を行います。`level`パラメータで記録するログレベルを指定し、`filename`でログの出力先を設定します。
- ログレベルは重要度順に CRITICAL > ERROR > WARNING > INFO > DEBUG であり、設定したレベル以上のログのみが記録されます。
- 変数を含むログメッセージは複数の方法で記録できますが、最後の方法（パラメータ渡し）が最も効率的です。

### 2. フォーマットの指定

ログの出力形式をカスタマイズするには、フォーマッターを使用します。以下のコードを実行してみましょう：

```python
import logging

# フォーマットを指定してログを設定
formatter = "%(levelname)s:%(message)s"
# 時刻を含めたい場合は以下のようにします
# formatter = "%(asctime)s:%(message)s"
logging.basicConfig(level=logging.DEBUG, format=formatter)

# 各レベルのログを出力
logging.critical("critical")
logging.error("error")
logging.warning("warning")
logging.info("info")
logging.debug("debug")

# 変数の値を含むログメッセージ
message = "テストメッセージ"
logging.debug(f"{message} aaa")
logging.debug("info %s %s" % ("test", "test2"))
logging.debug("info %s %s", "test", "test2")
```

実行結果（コンソール出力）：

```
CRITICAL:critical
ERROR:error
WARNING:warning
INFO:info
DEBUG:debug
DEBUG:テストメッセージ aaa
DEBUG:info test test2
DEBUG:info test test2
```

**解説：**
- `format`パラメータでログメッセージのフォーマットを指定できます。
- `%(levelname)s`はログレベル、`%(message)s`はメッセージ内容を表します。
- `%(asctime)s`を使用すると、タイムスタンプが含まれます。
- `filename`を指定しなかった場合、ログはコンソールに出力されます。

### 3. Logger オブジェクトの使用

より柔軟なロギングのために、専用のロガーオブジェクトを使用できます。次のコードを入力して実行してみましょう：

```python
import logging

# ルートロガーの設定
logging.basicConfig(level=logging.DEBUG)

# ルートロガーでログを出力
logging.info("info")

# 名前付きロガーを取得
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)  # このロガーのレベルを設定
logger.debug("debug")  # ロガーを使ってログを出力
```

実行結果：

```
INFO:root:info
DEBUG:__main__:debug
```

**解説：**
- `logging.getLogger(__name__)`で現在のモジュール名をベースにしたロガーを取得できます。
- これにより、異なるモジュールでのログを識別しやすくなります。
- `logger.setLevel()`でこのロガー専用のログレベルを設定できます。

### 4. ハンドラーの追加

ログメッセージを複数の場所（コンソールとファイルなど）に出力するには、ハンドラーを使用します：

```python
import logging

# ルートロガーの設定
logging.basicConfig(level=logging.DEBUG)

# ルートロガーでログを出力
logging.info("info")

# 名前付きロガーを取得
logger = logging.getLogger(__name__)

# ファイルハンドラーを作成して追加
file_handler = logging.FileHandler("logtest.log")
logger.addHandler(file_handler)

# ロガーのレベルを設定してログを出力
logger.setLevel(logging.DEBUG)
logger.debug("debug")
```

実行すると、コンソールには両方のログが表示され、`logtest.log`ファイルには２番目のログのみが記録されます。

**解説：**
- `FileHandler`を使用してファイルにログを出力するハンドラーを作成できます。
- `logger.addHandler()`でロガーにハンドラーを追加します。
- 複数のハンドラーを追加することで、同じログメッセージを異なる場所に同時に出力できます。

### 5. フィルターの使用

特定の条件に基づいてログをフィルタリングするには、カスタムフィルターを作成します：

```python
import logging

# ルートロガーの設定
logging.basicConfig(level=logging.INFO)

# 「password」という単語を含むログをフィルタリングするクラス
class NoPassFilter(logging.Filter):
    def filter(self, record):
        log_message = record.getMessage()
        return 'password' not in log_message  # True を返すとログが許可される

# ロガーを取得してフィルターを追加
logger = logging.getLogger(__name__)
logger.addFilter(NoPassFilter())

# ログメッセージを出力
logger.info("info")  # これは表示される
logger.info("info password")  # これはフィルタリングされる
```

実行結果：

```
INFO:__main__:info
```

**解説：**
- カスタムフィルターはlogging.Filterクラスを継承して作成します。
- `filter`メソッドが`True`を返すと、そのログは許可されます。
- ここでは「password」という単語を含むログメッセージをフィルタリングしています。

### 6. 設定ファイルの使用

ロギングの設定を外部ファイルで管理することもできます。以下のような`logging.ini`ファイルを作成します：

```ini
[loggers]
keys=root,simpleExample

[handlers]
keys=StreamHandler

[formatters]
keys=formatter

[logger_root]
level=WARNING
handlers=StreamHandler

[logger_simpleExample]
level=DEBUG
handlers=StreamHandler
qualname=simpleExample
propagate=0

[handler_StreamHandler]
class=StreamHandler
level=DEBUG
formatter=formatter
args=(sys.stderr,)

[formatter_formatter]
format=%(asctime)s %(name)-12s %(levelname)-8s %(message)s
```

次に、以下のコードでこの設定を読み込みます：

```python
import logging.config

# 設定ファイルを読み込む
logging.config.fileConfig("logging.ini")
logger = logging.getLogger("simpleExample")

# 各レベルのログを出力
logger.debug("debug")
logger.info("info")
logger.warning("warning")
logger.error("error")
logger.critical("critical")
```

実行結果：

```
2025-04-13 12:34:56 simpleExample DEBUG    debug
2025-04-13 12:34:56 simpleExample INFO     info
2025-04-13 12:34:56 simpleExample WARNING  warning
2025-04-13 12:34:56 simpleExample ERROR    error
2025-04-13 12:34:56 simpleExample CRITICAL critical
```

**解説：**
- `logging.config.fileConfig()`で設定ファイルを読み込みます。
- 設定ファイルにはロガー、ハンドラー、フォーマッターの定義を記述できます。
- `dictConfig`を使用してPythonの辞書形式で設定することも可能です。

### 7. 実践的なロギング例

実際のアプリケーションでは、以下のように構造化されたロギングを行うことが多いです：

```python
import logging

# ルートロガーの基本設定
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(),  # コンソール出力
        logging.FileHandler('app.log')  # ファイル出力
    ]
)

# クラス内でのロギング
class TestClass():
    def __init__(self):
        # クラス名をベースにしたロガーを取得
        self.logger = logging.getLogger(self.__class__.__name__)

    def save(self, file):
        # 処理開始のログ（構造化ログの例）
        self.logger.info({"action": "save", "file": file, "status": "run"})
        
        # 実際の処理
        print('do something')
        
        # 処理成功のログ
        self.logger.info({"action": "save", "file": file, "status": "success"})

# クラスのインスタンスを作成して実行
test_class = TestClass()
test_class.save("test.txt")
```

実行結果：

```
2025-04-13 12:34:56 - TestClass - INFO - {'action': 'save', 'file': 'test.txt', 'status': 'run'}
do something
2025-04-13 12:34:56 - TestClass - INFO - {'action': 'save', 'file': 'test.txt', 'status': 'success'}
```

**解説：**
- クラス内でロガーを使用する場合、`self.__class__.__name__`をロガー名として使うと、ログの発生源がわかりやすくなります。
- 構造化ログ（辞書形式）を使用すると、後でログ解析ツールで処理しやすくなります。
- 関数の開始と終了時にログを出力すると、処理の流れを追跡しやすくなります。

## まとめ

Pythonのロギングは以下の要素で構成されています：

1. **ロガー**: ログメッセージを生成する主体
2. **ハンドラー**: ログメッセージの出力先を定義
3. **フォーマッター**: ログメッセージの形式を定義
4. **フィルター**: 条件に基づいてログをフィルタリング

適切なロギングを実装することで、アプリケーションの動作状況を把握しやすくなり、問題解決が効率化されます。ログレベルを使い分けることで、開発時には詳細なログを、本番環境ではエラーのみを記録するといった柔軟な運用が可能になります。
