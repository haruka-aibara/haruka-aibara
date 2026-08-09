# datetime

## 概要
datetime モジュールは Python で日付と時刻を扱うための標準ライブラリで、日付計算やフォーマット変換などの操作を簡単に行えます。

## 基本概念
datetime モジュールには主に datetime, date, time, timedelta などのクラスがあり、それぞれ日時、日付、時刻、時間間隔を表現します。

## コード例とその実行方法

### 1. datetime クラスの基本的な使い方

以下のコードを入力して実行してみましょう：

```python
import datetime

# 現在の日時を取得
now = datetime.datetime.now()

# 様々な形式で出力
print(now)  # 標準形式での出力
print(now.isoformat())  # ISO 形式での出力
print(now.strftime('%d/%m/%y-%H%M%S%f'))  # カスタム形式での出力
```

**実行結果の例**：
```
2025-04-09 12:34:56.789012
2025-04-09T12:34:56.789012
09/04/25-123456789012
```

**解説**：
- `datetime.datetime.now()`：現在の日時を取得します
- `isoformat()`：ISO 8601 形式（YYYY-MM-DDTHH:MM:SS.mmmmmm）で出力します
- `strftime()`：指定したフォーマット文字列に従って出力します
  - `%d`：日、`%m`：月、`%y`：年（2桁）
  - `%H`：時間（24時間制）、`%M`：分、`%S`：秒、`%f`：マイクロ秒

### 2. date クラスの使い方

以下のコードを入力して実行してみましょう：

```python
import datetime

# 今日の日付を取得
today = datetime.date.today()

# 様々な形式で出力
print(today)  # 標準形式での出力
print(today.isoformat())  # ISO 形式での出力
print(today.strftime('%d/%m/%y'))  # カスタム形式での出力
```

**実行結果の例**：
```
2025-04-09
2025-04-09
09/04/25
```

**解説**：
- `datetime.date.today()`：今日の日付を取得します
- 日付のみを扱いたい場合は datetime ではなく date クラスを使うと便利です

### 3. time クラスの使い方

以下のコードを入力して実行してみましょう：

```python
import datetime

# 時刻を作成
current_time = datetime.time(hour=1, minute=10, second=5, microsecond=100)

# 様々な形式で出力
print(current_time)  # 標準形式での出力
print(current_time.isoformat())  # ISO 形式での出力
print(current_time.strftime('%H_%M_%S_%f'))  # カスタム形式での出力
```

**実行結果の例**：
```
01:10:05.000100
01:10:05.000100
01_10_05_000100
```

**解説**：
- `datetime.time()`：時、分、秒、マイクロ秒を指定して時刻オブジェクトを作成します
- 日付情報は持たず、時刻だけを扱いたい場合に便利です

### 4. 日時の計算（timedelta の使用）

以下のコードを入力して実行してみましょう：

```python
import datetime

# 現在の日時
now = datetime.datetime.now()
print(now)  # 現在の日時

# 1週間前の日時を計算
one_week = datetime.timedelta(weeks=1)
last_week = now - one_week
print(last_week)  # 1週間前の日時
```

**実行結果の例**：
```
2025-04-09 12:34:56.789012
2025-04-02 12:34:56.789012
```

**解説**：
- `datetime.timedelta`：日時間隔を表すクラスです
- timedelta オブジェクトを使って日時の加算・減算が可能です
- weeks, days, hours, minutes, seconds, microseconds などのパラメータで間隔を指定できます

### 5. time モジュールの基本的な使い方

以下のコードを入力して実行してみましょう：

```python
import time

print('### 処理開始 ###')
time.sleep(1)  # 1秒待機
print('### 処理終了 ###')

# UNIX時間（エポック秒）を取得
unix_time = time.time()
print(f"UNIX時間: {unix_time}")
```

**実行結果の例**：
```
### 処理開始 ###
### 処理終了 ###
UNIX時間: 1743689696.123456
```

**解説**：
- `time.sleep(秒数)`：指定した秒数だけプログラムの実行を一時停止します
- `time.time()`：UNIX時間（1970年1月1日からの経過秒数）を取得します

### 6. ファイル名にタイムスタンプを付ける実用例

以下のコードを入力して実行してみましょう：

```python
import datetime
import os
import shutil

# 現在の日時を取得
now = datetime.datetime.now()
file_name = 'test.txt'

# ファイルが存在する場合はバックアップを作成
if os.path.exists(file_name):
    backup_name = f"{file_name}_{now.strftime('%Y_%m_%d_%H_%M_%S')}.txt"
    shutil.copy(file_name, backup_name)
    print(f"バックアップファイルを作成しました: {backup_name}")

# ファイルに新しい内容を書き込み
with open(file_name, 'w') as f:
    f.write('テストデータ')
    
print(f"ファイル '{file_name}' を作成/更新しました")
```

**実行結果の例**：
最初の実行時:
```
ファイル 'test.txt' を作成/更新しました
```

2回目以降の実行時:
```
バックアップファイルを作成しました: test.txt_2025_04_09_12_34_56.txt
ファイル 'test.txt' を作成/更新しました
```

**解説**：
- ファイル名にタイムスタンプを付けて、日時ごとにユニークなファイル名を生成できます
- `strftime()`を使って日時を好きなフォーマットの文字列に変換できます
- このパターンはログファイルのローテーションやバックアップファイルの作成などに役立ちます
