# Flask

「Webhook を1本受けたい」「社内向けに小さな画面を1枚出したい」——そのために Django を立てるのは大げさ。**最小のコードで HTTP を受けられて、必要になったら育てられる**のが Flask。マイクロフレームワークの代表格で、Python の Web 入門としても定番。

## 最小構成の威力

```python
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.post("/webhook")
def webhook():
    event = request.get_json()
    handle(event)
    return jsonify(ok=True)
```

このファイル1枚で完結する。Django のようなプロジェクト構造の生成も設定も不要で、「HTTP で何かを受けて何かを返す」までの距離が最短。学習面でも、リクエスト・レスポンス・ルーティングという Web の基本要素が裸で見えるので、フレームワークの魔法に隠されずに理解できる。

## 「マイクロ」の意味：核だけ提供、あとは選んで足す

Flask 本体にあるのはルーティング、リクエスト/レスポンス、テンプレート（Jinja2）、セッション程度。DB・認証・フォーム検証・マイグレーションは**含まれない**。必要なら拡張を足す：

- DB/ORM → SQLAlchemy（Flask-SQLAlchemy）
- 認証 → Flask-Login
- マイグレーション → Flask-Migrate

これは自由度でもあり、責任でもある。Django なら標準で付いてくるもの（[12-11](12-11_Django.md)）を自分で選定・接着・維持することになり、アプリが育つほど「自前 Django」を組み立てている状態になりがち。**育つ見込みがあるなら最初から Django/FastAPI**、という判断も含めて「マイクロ」を理解しておく。

セキュリティも同じ構図で、テンプレートの自動エスケープはあるが、**CSRF 対策などは拡張（Flask-WTF）を入れて初めて付く**。「Flask で作った画面に CSRF 対策がない」は実際によくある指摘事項で、小さく始めたものが育ったときに監査観点が漏れやすい——マイクロフレームワークの構造的な注意点として覚えておく。

## 運用と現在地

同期型・WSGI の世界（[12-07](12-07_同期型.md)）なので、本番は gunicorn 等で動かす（`flask run` は開発用）。立ち位置としては：

- **小さなWeb ツール・webhook・プロトタイプ** → Flask が最軽量で最速
- **JSON API** → 新規なら FastAPI（[12-10](12-10_Fast API.md)）がバリデーションとドキュメントの分だけ有利
- **フルスタック** → Django

「小ささが正義である場面」は常にあるので、FastAPI 時代でも Flask の出番はなくならない。

## 参考

- [Flask 公式ドキュメント](https://flask.palletsprojects.com/)
- [Flask-WTF (CSRF Protection)](https://flask-wtf.readthedocs.io/en/latest/csrf/)
