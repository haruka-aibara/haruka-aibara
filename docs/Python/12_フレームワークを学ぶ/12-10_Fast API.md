# FastAPI

REST API を作るときの面倒ごとは、ルーティングよりその周辺にある——リクエストのバリデーション、型変換、エラーレスポンスの統一、そして API ドキュメントの維持。FastAPI はこれらを「**Python の型ヒントを書けば全部ついてくる**」に集約したフレームワークで、現在の Python API 開発の第一候補。

## 型ヒントがそのまま仕様になる

```python
from fastapi import FastAPI
from pydantic import BaseModel, Field

app = FastAPI()

class UserCreate(BaseModel):
    name: str = Field(min_length=1, max_length=50)
    age: int = Field(ge=0)

@app.post("/users", status_code=201)
async def create_user(user: UserCreate):
    return await save(user)
```

これだけで：

- **バリデーション**：age に "abc" が来れば 422 と詳細なエラー JSON を自動返却。手書きの検証コードが消える
- **型変換**：パスやクエリの文字列を宣言した型へ変換
- **ドキュメント**：`/docs` に Swagger UI が自動生成され、**実装と絶対に乖離しない** API 仕様書になる。「ドキュメントが古い」問題が構造的に消える

「入力を信用せず境界で検証する」というセキュアコーディングの基本を、書かなくても守れる形にしたのが本質的な価値。

## 同期・非同期の両対応

`def` と `async def` を混在でき、同期関数はスレッドプールに逃がされる（詳細は [12-09_同期型+非同期型](12-09_同期型+非同期型.md)）。「普通に書き始めて、必要な箇所だけ非同期化」ができるので、非同期の規律（[12-08](12-08_非同期型.md)）を最初から全員に強いなくて済む。

もうひとつの主要機能が **Depends による依存性注入**。「認証済みユーザーを取り出す」「DB セッションを渡す」を宣言的に書け、エンドポイントごとの認可チェック漏れを防ぐ構造を作りやすい：

```python
@app.get("/me")
async def me(user: User = Depends(get_current_user)):   # 認証必須が宣言で保証される
    return user
```

## 運用の型

本番は uvicorn（ASGI サーバー）で動かす。コンテナなら：

```dockerfile
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

エコシステムは Pydantic を軸に回っており、設定管理（pydantic-settings）・ORM（SQLModel）まで型ヒント文化で統一できる。Django のような「全部入り」（管理画面、ORM、認証。[12-11](12-11_Django.md)）は持たないので、フルスタックWebアプリなら Django、**API サーバーなら FastAPI** という棲み分けが現在の相場。

## 参考

- [FastAPI 公式ドキュメント](https://fastapi.tiangolo.com/ja/)
- [Pydantic — docs.pydantic.dev](https://docs.pydantic.dev/latest/)
