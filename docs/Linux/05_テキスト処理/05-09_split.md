# 【Linux講座】分割コマンド（split）

## 概要
Linuxのsplitコマンドは大きなファイルを複数の小さなファイルに分割するために使用され、大容量データの処理や管理を効率化します。

## 主要概念
splitコマンドは行数やバイト数を基準にファイルを分割し、分割されたファイルには自動的に連番が付けられます。

## 実践コマンド例

### 1. テスト用の大きなファイルを作成する

まずは分割するためのテストファイルを作成しましょう：

```bash
seq 1 100 > numbers.txt
```

このコマンドを入力して実行してみましょう。1から100までの数字を「numbers.txt」というファイルに書き込みます。

確認するには：

```bash
cat numbers.txt | wc -l
```

この結果、「100」と表示されるはずです。これは、ファイルに100行あることを示しています。

### 2. 行数で分割する

次に、このファイルを20行ごとに分割してみましょう：

```bash
split -l 20 numbers.txt part_
```

このコマンドを入力して実行してみましょう。`-l 20`オプションは「20行ごとに分割する」ことを意味し、`part_`は分割ファイルの接頭辞（プレフィックス）を指定します。

分割されたファイルを確認するには：

```bash
ls -l part_*
```

実行結果：
```
-rw-r--r-- 1 user group 60 Apr 23 10:00 part_aa
-rw-r--r-- 1 user group 60 Apr 23 10:00 part_ab
-rw-r--r-- 1 user group 60 Apr 23 10:00 part_ac
-rw-r--r-- 1 user group 60 Apr 23 10:00 part_ad
-rw-r--r-- 1 user group 60 Apr 23 10:00 part_ae
```

これにより、ファイルが5つに分割されたことがわかります（100行÷20行=5ファイル）。

各ファイルの内容を確認するには：

```bash
head -n 5 part_aa
```

実行結果：
```
1
2
3
4
5
```

```bash
head -n 5 part_ab
```

実行結果：
```
21
22
23
24
25
```

### 3. バイト数で分割する

次に、ファイルをバイト数で分割してみましょう：

```bash
split -b 50 numbers.txt byte_
```

このコマンドを入力して実行してみましょう。`-b 50`オプションは「50バイトごとに分割する」ことを意味します。

分割されたファイルを確認するには：

```bash
ls -l byte_*
```

実行結果は環境によって異なりますが、ファイルが複数に分割されたことが確認できます。

### 4. 分割したファイルに数値接尾辞を使用する

デフォルトでは、splitコマンドはアルファベット（aa, ab, ac...）を接尾辞として使用しますが、数値を使うこともできます：

```bash
split -l 20 --numeric-suffixes=1 numbers.txt num_
```

このコマンドを入力して実行してみましょう。`--numeric-suffixes=1`オプションは「1から始まる数値を接尾辞として使用する」ことを意味します。

分割されたファイルを確認するには：

```bash
ls -l num_*
```

実行結果：
```
-rw-r--r-- 1 user group 60 Apr 23 10:00 num_01
-rw-r--r-- 1 user group 60 Apr 23 10:00 num_02
-rw-r--r-- 1 user group 60 Apr 23 10:00 num_03
-rw-r--r-- 1 user group 60 Apr 23 10:00 num_04
-rw-r--r-- 1 user group 60 Apr 23 10:00 num_05
```

### 5. 接尾辞の桁数を指定する

接尾辞の桁数を指定することもできます：

```bash
split -l 20 --numeric-suffixes=1 --suffix-length=3 numbers.txt seq_
```

このコマンドを入力して実行してみましょう。`--suffix-length=3`オプションは「接尾辞の桁数を3桁にする」ことを意味します。

分割されたファイルを確認するには：

```bash
ls -l seq_*
```

実行結果：
```
-rw-r--r-- 1 user group 60 Apr 23 10:00 seq_001
-rw-r--r-- 1 user group 60 Apr 23 10:00 seq_002
-rw-r--r-- 1 user group 60 Apr 23 10:00 seq_003
-rw-r--r-- 1 user group 60 Apr 23 10:00 seq_004
-rw-r--r-- 1 user group 60 Apr 23 10:00 seq_005
```

### 6. 分割したファイルを結合する

分割したファイルを元に戻す（結合する）には、catコマンドを使用します：

```bash
cat part_* > restored.txt
```

このコマンドを入力して実行してみましょう。すべての「part_」で始まるファイルを結合して「restored.txt」というファイルを作成します。

結合したファイルが元のファイルと同じか確認するには：

```bash
diff numbers.txt restored.txt
```

何も表示されなければ、2つのファイルは同一です。

### 7. 圧縮ファイルを分割する

大きな圧縮ファイルを扱う場合も同様に分割できます。まず、テスト用の圧縮ファイルを作成します：

```bash
tar -czf archive.tar.gz numbers.txt
```

このコマンドを入力して実行してみましょう。「numbers.txt」をtar形式でアーカイブし、gzipで圧縮します。

次に、この圧縮ファイルを100バイトごとに分割します：

```bash
split -b 100 archive.tar.gz archive_
```

このコマンドを入力して実行してみましょう。

分割されたファイルを確認するには：

```bash
ls -l archive_*
```

これで、圧縮ファイルが複数の小さなファイルに分割されました。

分割したファイルを元に戻すには：

```bash
cat archive_* > restored.tar.gz
```

このコマンドを入力して実行してみましょう。

アーカイブが正しく復元されたか確認するには：

```bash
tar -tzf restored.tar.gz
```

実行結果に「numbers.txt」が表示されれば、アーカイブが正常に復元されたことを意味します。
