# Pythonのimport記述ルール

## 概要
Pythonプログラムにおけるimport文の記述には標準的な規約があり、これに従うことでコードの可読性と保守性が向上します。

## 基本概念
importの記述には優先順位があり、標準ライブラリ→サードパーティライブラリ→カスタムパッケージ→ローカルモジュールの順にグループ化することが推奨されます。

## step by stepコード例

### 1. 基本的なimportの書き方

次のコードを入力して実行してみましょう：

```python
# 推奨されない書き方（カンマ区切りでのimport）
import collections, os, sys

print("推奨されない書き方でもプログラムは動作します")
print(f"collections: {collections.__name__}")
print(f"os: {os.__name__}")
print(f"sys: {sys.__name__}")
```

実行結果：
```
推奨されない書き方でもプログラムは動作します
collections: collections
os: os
sys: sys
```

解説：
カンマ区切りでimportすることは技術的には可能ですが、PEP 8（Pythonコーディング規約）では推奨されていません。可読性が低下し、バージョン管理システムでの差分確認も難しくなります。

### 2. 推奨されるimportの書き方

次のコードを入力して実行してみましょう：

```python
# 推奨される書き方（各モジュールを別々の行でimport）
# 標準ライブラリ
import collections
import os
import sys

print("推奨される書き方")
print(f"collections: {collections.__name__}")
print(f"os: {os.__name__}")
print(f"sys: {sys.__name__}")
```

実行結果：
```
推奨される書き方
collections: collections
os: os
sys: sys
```

解説：
各モジュールを別々の行でimportすることで、コードの可読性が向上し、バージョン管理システムでの変更追跡が容易になります。また、アルファベット順に並べることも推奨されています。

### 3. モジュールグループの区分け

完全なimportの例を示します。次のコードを入力して実行してみましょう：

```python
# 標準ライブラリ（アルファベット順）
import collections
import os
import sys

# サードパーティライブラリ例
import termcolor

# カスタムパッケージ（自分で作成したパッケージ）
import lesson_package

# ローカルモジュール（同じディレクトリ内のモジュール）
import config

print("モジュールがグループごとに区分けされています")
print(f"標準ライブラリの例: {collections.__name__}, {os.__name__}, {sys.__name__}")
```

実行結果：
```
モジュールがグループごとに区分けされています
標準ライブラリの例: collections, os, sys
```

解説：
importを4つのグループに分けて記述することが推奨されています：
1. 標準ライブラリ（Pythonに標準で含まれているモジュール）
2. サードパーティライブラリ（pipなどでインストールしたモジュール）
3. カスタムパッケージ（自分で作成したパッケージ）
4. ローカルモジュール（同じディレクトリ内のモジュール）

各グループの間には空行を入れて視覚的に分離し、各グループ内ではアルファベット順に並べるとよいでしょう。
