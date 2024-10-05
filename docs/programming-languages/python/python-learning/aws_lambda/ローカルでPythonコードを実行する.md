特に event などを引き受ける必要がない場合の Lambda 関数の場合のみですが、コード内に以下の３行を追加すればそのまま python ~.py と呼びローカルで動作させることができます。

```
if __name__ == "__main__":
    result = lambda_handler(None, None)
    print(result)
```
