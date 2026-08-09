# PythonでCSVファイルを操作する

## 概要
CSVファイルはデータ交換の一般的な形式であり、Pythonでは`csv`モジュールを使って簡単に読み書きができます。

## 主要概念
`csv`モジュールは`DictWriter`と`DictReader`クラスを提供し、CSVファイルをPythonの辞書形式で簡単に操作できます。

## ステップバイステップのコード例

### 1. CSVファイルの作成と書き込み

まずは新しいCSVファイルを作成して、データを書き込んでみましょう。以下のコードを入力して実行してみましょう。

```python
import csv

# CSVファイルを書き込みモードで開く
with open('test.csv', 'w') as csv_file:
    # ヘッダー行（列名）を定義
    fieldnames = ['Name', 'Count']
    
    # DictWriterオブジェクトを作成
    writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
    
    # ヘッダー行を書き込む
    writer.writeheader()
    
    # データ行を辞書形式で書き込む
    writer.writerow({'Name': 'A', 'Count': 1})
    writer.writerow({'Name': 'B', 'Count': 2})
```

このコードを実行すると、カレントディレクトリに`test.csv`というファイルが作成されます。ファイルを開くと以下のような内容になっているはずです：

```
Name,Count
A,1
B,2
```

### 2. CSVファイルの読み込みと表示

次に、作成したCSVファイルを読み込んで内容を表示してみましょう。以下のコードを入力して実行してみましょう。

```python
import csv

# CSVファイルを読み込みモードで開く
with open('test.csv', 'r') as csv_file:
    # DictReaderオブジェクトを作成
    reader = csv.DictReader(csv_file)
    
    # 各行を辞書形式で読み込む
    for row in reader:
        print(row['Name'], row['Count'])
```

このコードを実行すると、以下のような出力が表示されます：

```
A 1
B 2
```

### 3. 完全な例

以下のコードは、CSVファイルの作成と読み込みを一度に行う完全な例です。このコードを入力して実行してみましょう。

```python
import csv

# CSVファイルの作成と書き込み
with open('test.csv', 'w') as csv_file:
    # ヘッダー行（列名）を定義
    fieldnames = ['Name', 'Count']
    
    # DictWriterオブジェクトを作成
    writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
    
    # ヘッダー行を書き込む
    writer.writeheader()
    
    # データ行を辞書形式で書き込む
    writer.writerow({'Name': 'A', 'Count': 1})
    writer.writerow({'Name': 'B', 'Count': 2})

print("CSVファイルへの書き込みが完了しました。")

# CSVファイルの読み込みと表示
with open('test.csv', 'r') as csv_file:
    # DictReaderオブジェクトを作成
    reader = csv.DictReader(csv_file)
    
    print("\nCSVファイルの内容:")
    # 各行を辞書形式で読み込む
    for row in reader:
        print(f"名前: {row['Name']}, カウント: {row['Count']}")
```

このコードを実行すると、以下のような出力が表示されます：

```
CSVファイルへの書き込みが完了しました。

CSVファイルの内容:
名前: A, カウント: 1
名前: B, カウント: 2
```

## まとめ

Pythonの`csv`モジュールを使うと、以下のように簡単にCSVファイルを操作できます：

1. `DictWriter`クラスを使ってCSVファイルに書き込む
2. `DictReader`クラスを使ってCSVファイルから読み込む
3. 辞書形式でデータを扱うことで、列名を使って直感的にデータにアクセスできる
