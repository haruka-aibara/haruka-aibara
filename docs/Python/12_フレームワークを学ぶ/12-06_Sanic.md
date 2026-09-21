# Sanic

Flask の書き味のまま非同期で書けるフレームワークが欲しい——Sanic は「Flask ライクな API ＋ async/await ネイティブ」を最初期（2016年、Python 3.5 の async/await 直後）に実現したフレームワーク。名前は速さの象徴のあのハリネズミのもじりで、実際「速さ」を看板にしている。

## 書き味

```python
from sanic import Sanic, json

app = Sanic("MyApp")

@app.get("/users/<user_id:int>")
async def get_user(request, user_id: int):
    user = await fetch_user(user_id)     # 非同期I/O前提
    return json({"id": user.id, "name": user.name})

# 内蔵サーバーがそのまま本番想定（uvicorn等を別途立てなくてよい）
# sanic myapp:app --workers 4
```

Flask 経験者なら見た瞬間に書ける程度に似ている。特徴的なのは：

- **サーバー内蔵**：uvicorn / gunicorn を別に用意しなくても、マルチワーカーの本番運用まで面倒を見る設計
- **WebSocket、ストリーミング、ミドルウェア、Blueprint**（Flask 同様のモジュール分割）を標準装備
- 全編 async 前提なので、同期ライブラリを混ぜてはいけない規律（[12-08_非同期型](12-08_非同期型.md)）がそのまま適用される

## FastAPI との違い・選び分け

「非同期で速い Python API」の座は現在 FastAPI が事実上の第一候補で、Sanic を選ぶかはこの比較になる：

| | Sanic | FastAPI |
|---|---|---|
| 型ヒント連動のバリデーション | なし（自前 or 拡張） | **Pydantic で自動** |
| OpenAPI ドキュメント自動生成 | 拡張で | **標準** |
| サーバー | 内蔵 | uvicorn 等を組み合わせ |
| 立ち位置 | 素の非同期 Web サーバー・フレームワーク | API 開発特化の全部入り |

**スキーマ付きの REST API を作るなら FastAPI** が近道。一方、バリデーションや OpenAPI が不要な**軽量プロキシ、WebSocket サーバー、内部マイクロサービス**のような「余計な層のない非同期 HTTP」が欲しい場面では、Sanic のシンプルさと内蔵サーバーの手軽さが今も活きる。

歴史的な意義（async ネイティブ Web フレームワークの先駆）も含めて、「非同期型の選択肢の一つ。ただし新規のAPI開発ならまず FastAPI と比較してから」という位置づけで押さえておけばよい。

## 参考

- [Sanic — sanic.dev](https://sanic.dev/en/)
- [Sanic — GitHub](https://github.com/sanic-org/sanic)
