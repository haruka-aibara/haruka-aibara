# Pythonの正規表現：re.group、re.compile、re.VERBOSEの使い方

## 1. 概要と重要性

正規表現は複雑な文字列パターンを検索・抽出するための強力なツールであり、Pythonの`re`モジュールでは`group`、`compile`、`VERBOSE`機能を使って効率的かつ読みやすいパターンマッチングを実現できます。

## 2. 主要概念の説明

Pythonの`re`モジュールは、`compile`で正規表現パターンをコンパイルして再利用性を高め、`group`で一致した部分文字列を取得し、`VERBOSE`モードでパターンを読みやすく記述することができます。

## 3. 実践コード例

### 基本的な使い方

まずは`re`モジュールをインポートし、サンプル文字列を準備します。

```python
import re

# AWSのCloudFormationスタックIDサンプル
s1 = "arn:aws:cloudformation:us-west-2:123456789012:stack/teststack/51af3dc0-da77-11e4-872e-1234567db123"
s2 = "arn:aws:cloudformation:us-west-2:123456789012:stack/teststack-2/51af3dc0-da77-11e4-872e-1234567db123"
```

このコードを入力して実行してみましょう。変数`s1`と`s2`にAWSのCloudFormationスタックIDを格納しました。

### re.compile と名前付きグループの利用

次に、正規表現パターンをコンパイルし、名前付きグループを定義します。

```python
# 正規表現パターンをコンパイル
RE_STACK_ID = re.compile(
    r"""arn:aws:cloudformation:
    (?P<region>[\w-]+):                           # region
    (?P<account_id>[\d]+)                         # account_id
    :stack/
    (?P<stack_name>[\w-]+)                        # stack_name
    /[\w-]+""",
    re.VERBOSE,
)
```

このコードを入力して実行してみましょう。ここでは`re.compile()`を使って正規表現パターンをコンパイルし、`RE_STACK_ID`という変数に格納しています。`(?P<名前>パターン)`という形式で名前付きグループを定義し、`re.VERBOSE`オプションを使って複数行・コメント付きの正規表現を記述しています。

### マッチングと結果の取得

コンパイルしたパターンを使って文字列をマッチングし、結果を取得します。

```python
for s in [s1, s2]:
    # パターンとマッチングを行う
    m = RE_STACK_ID.match(s)
    if m:
        print("go next")
        # group()メソッドで名前付きグループの値を取得
        print(m.group("region"))
        print(m.group("account_id"))
        print(m.group("stack_name"))
    else:
        raise Exception("error")

# マッチオブジェクトの詳細情報
print(m)
```

このコードを入力して実行してみましょう。実行結果は以下のようになります：

```
go next
us-west-2
123456789012
teststack
go next
us-west-2
123456789012
teststack-2
<re.Match object; span=(0, 102), match='arn:aws:cloudformation:us-west-2:123456789012:>
```

上記の結果から、以下のことがわかります：
- 両方の文字列が正規表現パターンとマッチしました
- `group()`メソッドを使って名前付きグループの値を取得できました
- `s1`からは`region`が`us-west-2`、`account_id`が`123456789012`、`stack_name`が`teststack`と抽出されました
- `s2`からは`region`が`us-west-2`、`account_id`が`123456789012`、`stack_name`が`teststack-2`と抽出されました
- 最後の行はマッチオブジェクト自体の情報を表示しています

## まとめ

この例では、Pythonの正規表現における以下の機能を学びました：

1. **re.compile**: 正規表現パターンをコンパイルして再利用することで、複数回のマッチングを効率的に行えます。
2. **re.VERBOSE**: 正規表現パターンを複数行に分けて書き、コメントを付けることで可読性を高められます。
3. **名前付きグループと.group()**: `(?P<名前>パターン)`で名前付きグループを定義し、`.group("名前")`でその部分を抽出できます。

これらの機能を活用することで、複雑な正規表現も見やすく、メンテナンスしやすいコードになります。
