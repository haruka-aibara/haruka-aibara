# Pythonによるファイル操作

## 概要
ファイル操作はプログラミングにおいて不可欠なスキルであり、データの読み書きやファイルシステムの管理に必要です。

## 主要概念
Pythonでは`os`、`pathlib`、`glob`、`shutil`などのモジュールを使用してファイルやディレクトリの操作を行います。

## 基本的なファイル操作

### ファイルやディレクトリの存在確認と基本操作

まずは`os`モジュールを使用した基本的なファイル操作を見ていきましょう。

```python
import os

# ファイルの存在確認
# os.path.exists()は指定したパスが存在するかどうかを確認します
print("ファイル 'test.txt' は存在しますか？:", os.path.exists('test.txt'))

# ファイルかどうかの確認
# os.path.isfile()は指定したパスがファイルかどうかを確認します
print("'test.txt' はファイルですか？:", os.path.isfile('test.txt'))

# ディレクトリかどうかの確認
# os.path.isdir()は指定したパスがディレクトリかどうかを確認します
print("'test' はディレクトリですか？:", os.path.isdir('test'))

# ファイル名の変更
# os.rename()はファイル名を変更します
# このコードを実行する前に、test.txtというファイルを作成しておいてください
os.rename('test.txt', 'renamed.txt')
print("ファイル名を 'test.txt' から 'renamed.txt' に変更しました")

# シンボリックリンクの作成
# os.symlink()はシンボリックリンクを作成します
# Windows環境では管理者権限が必要な場合があります
try:
    os.symlink('renamed.txt', 'symlink.txt')
    print("'renamed.txt' へのシンボリックリンク 'symlink.txt' を作成しました")
except OSError as e:
    print(f"シンボリックリンクの作成に失敗しました: {e}")

# ディレクトリの作成
# os.mkdir()は新しいディレクトリを作成します
os.mkdir('test_dir')
print("ディレクトリ 'test_dir' を作成しました")

# ディレクトリの削除
# os.rmdir()は空のディレクトリを削除します
os.rmdir('test_dir')
print("ディレクトリ 'test_dir' を削除しました")
```

このコードを入力して実行してみましょう。実行前に`test.txt`というファイルを作成しておく必要があります。

**実行結果の例**:
```
ファイル 'test.txt' は存在しますか？: True
'test.txt' はファイルですか？: True
'test' はディレクトリですか？: False
ファイル名を 'test.txt' から 'renamed.txt' に変更しました
'renamed.txt' へのシンボリックリンク 'symlink.txt' を作成しました
ディレクトリ 'test_dir' を作成しました
ディレクトリ 'test_dir' を削除しました
```

注意: 環境によっては`os.symlink()`がエラーを返す場合があります。特にWindowsでは管理者権限が必要です。

### 高度なファイル操作

次に、より高度なファイル操作について見ていきましょう。ここでは`pathlib`、`glob`、`shutil`モジュールも使用します。

```python
import glob
import os
import pathlib
import shutil

# 空のファイルを作成
# pathlib.Path().touch()は空のファイルを作成します
pathlib.Path('empty.txt').touch()
print("空のファイル 'empty.txt' を作成しました")

# ファイルの削除
# os.remove()はファイルを削除します
os.remove('empty.txt')
print("ファイル 'empty.txt' を削除しました")

# ディレクトリ構造の作成
# 親ディレクトリと子ディレクトリを作成します
os.mkdir('test_dir')
os.mkdir('test_dir/test_dir2')
print("ディレクトリ構造 'test_dir/test_dir2' を作成しました")

# ディレクトリの内容を表示
# os.listdir()はディレクトリ内のファイルとディレクトリをリストで返します
print("'test_dir' の内容:", os.listdir('test_dir'))

# ディレクトリ内にファイルを作成
pathlib.Path('test_dir/test_dir2/empty.txt').touch()
print("'test_dir/test_dir2/empty.txt' を作成しました")

# globを使ったファイルの検索
# glob.glob()はパターンにマッチするパスのリストを返します
print("'test_dir/test_dir2/' 内のファイル:", glob.glob('test_dir/test_dir2/*'))

# ファイルのコピー
# shutil.copy()はファイルをコピーします
shutil.copy('test_dir/test_dir2/empty.txt', 'test_dir/test_dir2/empty2.txt')
print("'empty.txt' を 'empty2.txt' にコピーしました")

# ディレクトリツリーの削除
# shutil.rmtree()はディレクトリとその中のすべての内容を削除します
shutil.rmtree('test_dir')
print("ディレクトリ 'test_dir' とその内容をすべて削除しました")

# 現在の作業ディレクトリを取得
# os.getcwd()は現在の作業ディレクトリのパスを返します
print("現在の作業ディレクトリ:", os.getcwd())
```

このコードを入力して実行してみましょう。

**実行結果の例**:
```
空のファイル 'empty.txt' を作成しました
ファイル 'empty.txt' を削除しました
ディレクトリ構造 'test_dir/test_dir2' を作成しました
'test_dir' の内容: ['test_dir2']
'test_dir/test_dir2/empty.txt' を作成しました
'test_dir/test_dir2/' 内のファイル: ['test_dir/test_dir2/empty.txt']
'empty.txt' を 'empty2.txt' にコピーしました
ディレクトリ 'test_dir' とその内容をすべて削除しました
現在の作業ディレクトリ: /Users/username/projects
```

## まとめ

Pythonでは以下のようなファイル操作が可能です：

1. ファイルやディレクトリの存在確認 (`os.path.exists`, `os.path.isfile`, `os.path.isdir`)
2. ファイル名の変更 (`os.rename`)
3. シンボリックリンクの作成 (`os.symlink`)
4. ディレクトリの作成と削除 (`os.mkdir`, `os.rmdir`)
5. 空ファイルの作成 (`pathlib.Path().touch()`)
6. ファイルの削除 (`os.remove`)
7. ディレクトリの内容確認 (`os.listdir`)
8. パターンマッチングによるファイル検索 (`glob.glob`)
9. ファイルのコピー (`shutil.copy`)
10. ディレクトリツリーの削除 (`shutil.rmtree`)
11. 現在の作業ディレクトリの取得 (`os.getcwd`)

これらの操作を理解することで、Pythonによる基本的なファイル管理が可能になります。
