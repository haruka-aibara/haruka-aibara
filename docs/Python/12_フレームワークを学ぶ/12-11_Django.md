# Django

「ログイン機能、管理画面、DB マイグレーション、CSRF 対策……アプリの本題に入る前の下ごしらえが多すぎる」——この下ごしらえを全部標準装備で持っているのが Django。「batteries included（全部入り）」を掲げる、Python で最も歴史と実績のあるフルスタック Web フレームワーク。

## 全部入りの中身

Flask や FastAPI が「コアは小さく、必要なものを足す」思想なのに対し、Django は最初から揃っている：

- **ORM ＋マイグレーション**：モデル定義から SQL・スキーマ変更を自動生成
- **管理画面（admin）**：モデルを登録するだけで CRUD の管理 UI が生える。社内ツールならこれだけで完結することも
- **認証・セッション**：ユーザー管理、パスワードハッシュ、権限グループが組み込み
- **フォーム、テンプレート、キャッシュ、i18n…**

```python
# models.py — これだけで DB テーブル・マイグレーション・管理画面の元になる
class Article(models.Model):
    title = models.CharField(max_length=200)
    body = models.TextField()
    published_at = models.DateTimeField(null=True)
```

「選定と接着に時間を使わず、規約に乗って進む」のが Django の速さ。逆に規約から外れたいとき（特殊な DB 設計、ORM を使わない等）は窮屈になる、という表裏でもある。

## セキュリティ既定値が堅い、という美点

Django を推す実務的理由として意外に大きいのがこれ。**CSRF 対策・XSS 対策（テンプレートの自動エスケープ）・SQL インジェクション対策（ORM）・クリックジャッキング対策が既定で有効**で、パスワードハッシュも現代的な設定が最初から入っている。「フレームワークが素の分、対策を自分で積む」型の構成と比べて、初学者やスピード優先のチームが**知らずに空ける穴**が構造的に少ない。セキュリティレビューをする側から見ても、Django 標準に乗っているコードは確認事項が減る。

## 選び分けと現在地

- **管理画面つきの業務アプリ・コンテンツ系サイト・ユーザー認証のあるフルスタック開発** → Django が最短。特に「管理画面が要る」なら他の追随を許さない
- **JSON API サーバー** → FastAPI（[12-10](12-10_Fast API.md)）が主流。Django でやるなら Django REST Framework を足すが、API 専用なら過積載気味
- **小さなツール・数エンドポイント** → Flask（[12-12](12-12_Flask.md)）程度が身軽

async 対応（ASGI、async ビュー）も進んでいるが、ORM 含め完全ではなく、「同期型の代表格で、非同期は部分対応」（[12-07](12-07_同期型.md)）という理解が現状に合う。

## 参考

- [Django 公式ドキュメント](https://docs.djangoproject.com/ja/stable/)
- [Security in Django — Django 公式ドキュメント](https://docs.djangoproject.com/en/stable/topics/security/)
