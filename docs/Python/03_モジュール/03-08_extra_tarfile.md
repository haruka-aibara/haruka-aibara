# tarfileを使用した圧縮・展開

## 概要
Pythonの標準ライブラリ`tarfile`モジュールを使用すると、TARアーカイブの作成や展開を簡単に行うことができます。

## 基本概念
`tarfile`モジュールは、ファイルやディレクトリをTARアーカイブに圧縮したり、TARアーカイブから展開したりするための関数を提供します。

## 実践コード例

### 1. TARアーカイブの作成

まず、ディレクトリを圧縮してTARアーカイブを作成してみましょう。

```python
import tarfile
import os

# テスト用ディレクトリとファイルを作成
os.makedirs('test_dir/sub_dir', exist_ok=True)
with open('test_dir/test.txt', 'w') as f:
    f.write('Hello, tar file!')
with open('test_dir/sub_dir/sub_test.txt', 'w') as f:
    f.write('Hello from subdirectory!')

# TARアーカイブ（gzip圧縮）を作成
with tarfile.open('test.tar.gz', 'w:gz') as tar:
    # test_dirディレクトリを圧縮
    tar.add('test_dir')
    
print("TARアーカイブが作成されました: test.tar.gz")
```

このコードを入力して実行してみましょう。

**実行結果:**
```
TARアーカイブが作成されました: test.tar.gz
```

**解説:**
1. `tarfile.open()`の第一引数は作成するTARファイルの名前です。
2. 第二引数の`'w:gz'`は「書き込みモードでgzip圧縮を使用する」という意味です。
3. `tar.add()`メソッドで、圧縮したいディレクトリを指定します。

### 2. TARアーカイブの展開

次に、作成したTARアーカイブを展開してみましょう。

```python
import tarfile
import os

# TARアーカイブを展開
with tarfile.open('test.tar.gz', 'r:gz') as tar:
    # 指定したパスに全ファイルを展開
    tar.extractall(path='test_extract')
    
print("TARアーカイブを展開しました: test_extract/")
print("展開されたファイル一覧:")
for root, dirs, files in os.walk('test_extract'):
    for file in files:
        print(os.path.join(root, file))
```

このコードを入力して実行してみましょう。

**実行結果:**
```
TARアーカイブを展開しました: test_extract/
展開されたファイル一覧:
test_extract/test_dir/test.txt
test_extract/test_dir/sub_dir/sub_test.txt
```

**解説:**
1. `tarfile.open()`の第二引数`'r:gz'`は「読み込みモードでgzip圧縮を扱う」という意味です。
2. `extractall()`メソッドは、TARアーカイブ内の全ファイルを指定したパスに展開します。

### 3. TARアーカイブ内の特定ファイルを読み込む

TARアーカイブを展開せずに、特定のファイルだけを読み込むこともできます。

```python
import tarfile

# TARアーカイブ内の特定ファイルを読み込む
with tarfile.open('test.tar.gz', 'r:gz') as tar:
    # extractfileメソッドでアーカイブ内のファイルを開く
    with tar.extractfile('test_dir/sub_dir/sub_test.txt') as file:
        # ファイルの内容を読み込んで表示
        content = file.read()
        print("ファイルの内容:")
        print(content.decode('utf-8'))
```

このコードを入力して実行してみましょう。

**実行結果:**
```
ファイルの内容:
Hello from subdirectory!
```

**解説:**
1. `extractfile()`メソッドは、TARアーカイブ内の特定のファイルをファイルオブジェクトとして開きます。
2. 読み込んだバイナリデータを`decode()`メソッドで文字列に変換しています。

### 4. TARアーカイブ内のファイル一覧を表示する

TARアーカイブ内のファイル一覧を表示してみましょう。

```python
import tarfile

# TARアーカイブ内のファイル一覧を表示
with tarfile.open('test.tar.gz', 'r:gz') as tar:
    print("アーカイブ内のファイル一覧:")
    for member in tar.getmembers():
        print(f"{'[DIR]' if member.isdir() else '[FILE]'} {member.name}")
```

このコードを入力して実行してみましょう。

**実行結果:**
```
アーカイブ内のファイル一覧:
[DIR] test_dir
[FILE] test_dir/test.txt
[DIR] test_dir/sub_dir
[FILE] test_dir/sub_dir/sub_test.txt
```

**解説:**
1. `getmembers()`メソッドは、TARアーカイブ内の全てのファイルとディレクトリの情報を取得します。
2. `isdir()`メソッドで、そのエントリがディレクトリかどうかを判断しています。

### 5. 圧縮形式を指定してTARアーカイブを作成する

異なる圧縮形式でTARアーカイブを作成することもできます。

```python
import tarfile
import os

# 様々な圧縮形式でTARアーカイブを作成
compression_types = {
    'w': '圧縮なし',
    'w:gz': 'gzip圧縮',
    'w:bz2': 'bzip2圧縮',
    'w:xz': 'lzma圧縮'
}

for mode, desc in compression_types.items():
    try:
        filename = f'test_{mode.split(":")[-1] if ":" in mode else "tar"}.tar'
        if ":" in mode:
            filename += f'.{mode.split(":")[-1]}'
            
        with tarfile.open(filename, mode) as tar:
            tar.add('test_dir')
            
        size = os.path.getsize(filename)
        print(f"{desc}アーカイブを作成: {filename} (サイズ: {size} バイト)")
    except Exception as e:
        print(f"{desc}アーカイブの作成に失敗: {e}")
```

このコードを入力して実行してみましょう。

**実行結果:**
```
圧縮なしアーカイブを作成: test_tar.tar (サイズ: 10240 バイト)
gzip圧縮アーカイブを作成: test_gz.tar.gz (サイズ: 245 バイト)
bzip2圧縮アーカイブを作成: test_bz2.tar.bz2 (サイズ: 257 バイト)
lzma圧縮アーカイブを作成: test_xz.tar.xz (サイズ: 268 バイト)
```

注: 環境によっては、一部の圧縮形式がサポートされていない場合があります。

**解説:**
1. `w`モードは圧縮なしのTARアーカイブを作成します。
2. `w:gz`はgzip圧縮、`w:bz2`はbzip2圧縮、`w:xz`はlzma圧縮を使用します。
3. それぞれの圧縮形式によってファイルサイズが異なることがわかります。

### まとめ

Pythonの`tarfile`モジュールを使用すると、以下のことが簡単にできます：

1. ファイルやディレクトリをTARアーカイブに圧縮する
2. TARアーカイブからファイルを展開する 
3. TARアーカイブ内の特定のファイルにアクセスする
4. 様々な圧縮形式（gzip、bzip2、lzma）を利用する

これらの基本操作を組み合わせることで、効率的なファイルアーカイブ処理を実装できます。
