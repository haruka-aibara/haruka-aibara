# zipfileモジュールを使った圧縮・展開

## 概要
Pythonの`zipfile`モジュールを使うと、ZIPファイルの作成、読み込み、展開などの操作を簡単に行うことができます。

## 主要概念
`zipfile`モジュールは、ファイルやディレクトリの圧縮・展開を行うためのクラスやメソッドを提供しています。

## 具体的な使い方

### 準備

まずは動作確認用のディレクトリとファイルを作成しましょう。以下のような構造を想定します：

```
現在のディレクトリ
└── test_dir
    └── test.txt
```

### 1. 基本的なZIPファイルの作成

以下のコードを入力して実行してみましょう：

```python
import zipfile

# 新しいZIPファイルを作成し、指定したファイルを追加
with zipfile.ZipFile('test.zip', 'w') as zip_file:
    # ディレクトリを追加
    zip_file.write('test_dir')
    # ファイルを追加
    zip_file.write('test_dir/test.txt')
```

**実行結果**: `test.zip`というZIPファイルが作成され、`test_dir`ディレクトリと`test_dir/test.txt`ファイルが含まれます。

**解説**: 
- `zipfile.ZipFile()`でZIPファイルのオブジェクトを作成します。
- 第1引数は作成するZIPファイルの名前、第2引数の`'w'`は書き込みモードを意味します。
- `write()`メソッドで、指定したファイルやディレクトリをZIPファイルに追加します。
- `with`文を使うことで、処理終了後に自動的にZIPファイルが閉じられます。

### 2. 複数ファイルの一括追加

ディレクトリ内のすべてのファイルを再帰的に追加するには、`glob`モジュールと組み合わせるのが便利です。

以下のコードを入力して実行してみましょう：

```python
import zipfile
import glob

# 新しいZIPファイルを作成し、ディレクトリ内のすべてのファイルを追加
with zipfile.ZipFile('test2.zip', 'w') as zip_file:
    # test_dirディレクトリ内のすべてのファイルを再帰的に取得
    for file_path in glob.glob('test_dir/**', recursive=True):
        print(file_path)  # 追加するファイルのパスを表示
        zip_file.write(file_path)
```

**実行結果**:
```
test_dir
test_dir/test.txt
```

`test2.zip`というZIPファイルが作成され、`test_dir`ディレクトリとその中のすべてのファイルが含まれます。

**解説**:
- `glob.glob()`関数で、指定したパターンに一致するファイルパスを取得します。
- `'test_dir/**'`は`test_dir`ディレクトリ内のすべてのファイルとディレクトリを意味します。
- `recursive=True`オプションを指定することで、サブディレクトリも再帰的に検索します。
- 各ファイルパスに対して`write()`メソッドを実行し、ZIPファイルに追加しています。

### 3. ZIPファイルの展開

ZIPファイルを展開するには、`extractall()`メソッドを使用します。

以下のコードを入力して実行してみましょう：

```python
import zipfile

# ZIPファイルを読み込みモードで開き、すべてのファイルを展開
with zipfile.ZipFile('test.zip', 'r') as zip_file:
    # ファイルをzzzz ディレクトリに展開
    zip_file.extractall('zzzz')
```

**実行結果**: `zzzz`というディレクトリが作成され、その中に`test_dir`ディレクトリと`test_dir/test.txt`ファイルが展開されます。

**解説**:
- `zipfile.ZipFile()`の第2引数に`'r'`を指定することで、読み込みモードでZIPファイルを開きます。
- `extractall()`メソッドで、ZIPファイル内のすべてのファイルを指定したディレクトリに展開します。
- 引数を省略すると、現在のディレクトリに展開されます。

### 4. ZIPファイル内の特定のファイルを読み込む

ZIPファイルを展開せずに、内部のファイルの内容を直接読み込むこともできます。

以下のコードを入力して実行してみましょう：

```python
import zipfile

# ZIPファイルを読み込みモードで開き、特定のファイルの内容を読み込む
with zipfile.ZipFile('test.zip', 'r') as zip_file:
    # ZIPファイル内の特定のファイルを開く
    with zip_file.open('test_dir/test.txt') as file:
        # ファイルの内容を読み込んで表示
        content = file.read()
        print(content)
```

**実行結果**: `test_dir/test.txt`ファイルの内容がバイト列として表示されます。

**解説**:
- `open()`メソッドで、ZIPファイル内の特定のファイルをファイルオブジェクトとして開きます。
- `read()`メソッドで、ファイルの内容を読み込みます。
- 読み込まれた内容はバイト列なので、テキストとして処理したい場合は必要に応じて`decode()`メソッドでデコードします。

## まとめ

Pythonの`zipfile`モジュールを使うことで、以下のことが簡単にできます：

1. ZIPファイルの作成と特定のファイルの追加
2. ディレクトリ内のすべてのファイルを再帰的にZIPファイルに追加
3. ZIPファイルのすべての内容を指定したディレクトリに展開
4. ZIPファイル内の特定のファイルの内容を読み込む

これらの操作を組み合わせることで、効率的なファイル圧縮・展開処理を実装できます。
