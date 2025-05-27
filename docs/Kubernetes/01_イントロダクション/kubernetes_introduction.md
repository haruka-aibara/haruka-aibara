---
marp: true
theme: default
paginate: true
style: |
  section {
    font-family: "Meiryo", "Noto Sans JP", "Hiragino Sans", "Hiragino Kaku Gothic ProN", sans-serif;
    color: #333;
    padding: 45px 35px 35px 35px;
    position: relative;
  }

  .header-bar {
    position: absolute;
    top: 0; left: 0; right: 0;
    height: 48px;
    background: #444;
    color: #fff;
    font-size: 1.1em;
    font-weight: bold;
    line-height: 48px;
    padding-left: 28px;
    letter-spacing: 0.08em;
    z-index: 10;
    box-sizing: border-box;
  }

  h1, h2 {
    font-weight: 700;
    letter-spacing: 0.01em;
    margin-bottom: 0.25em;
  }

  h1 {
    font-size: 1.6em;
    color: #333;
    border-bottom: 1px solid #1976d2;
    padding-bottom: 0.1em;
    margin-bottom: 0.4em;
  }

  h2 {
    font-size: 1.3em;
    color: #1976d2;
  }

  p, li {
    font-size: 0.9em;
    line-height: 1.4;
  }

  .problem {
    background: #ffebee;
    border-left: 4px solid #f44336;
    padding: 0.5em 1em;
    margin: 0.5em 0;
    font-size: 0.85em;
  }

  .solution {
    background: #e8f5e9;
    border-left: 4px solid #4caf50;
    padding: 0.5em 1em;
    margin: 0.5em 0;
    font-size: 0.85em;
  }

  .note {
    background: #fff3cd;
    border-left: 4px solid #ffc107;
    padding: 0.5em 1em;
    margin: 0.5em 0;
    font-size: 0.85em;
  }

  .illustration {
    max-width: 400px;
    margin: 1em auto;
  }

  .cover {
    text-align: center;
    padding-top: 100px;
  }

  .cover h1 {
    font-size: 2.5em;
    color: #1976d2;
    border: none;
    margin-bottom: 0.5em;
  }

  .cover .subtitle {
    font-size: 1.2em;
    color: #666;
    margin-bottom: 2em;
  }

  .toc {
    padding-top: 50px;
  }

  .toc h2 {
    text-align: center;
    margin-bottom: 1em;
  }

  .toc ul {
    list-style: none;
    padding: 0;
  }

  .toc li {
    margin: 0.5em 0;
    font-size: 1.1em;
  }

  .toc .page {
    color: #666;
    font-size: 0.8em;
    margin-left: 0.5em;
  }
---
<div class="header-bar">Kubernetes イントロダクション</div>

<div class="cover">

# Kubernetesって何？ 🚢

<div class="subtitle">
コンテナの世界の船長さん！
</div>

![width:400px](https://illustimage.com/photo/illust/2023/12/01/cover.png)

</div>

---
<div class="header-bar">Kubernetes イントロダクション</div>

<div class="toc">

# 目次 📑

1. コンテナの世界の困りごと <span class="page">3</span>
2. Kubernetesが解決する問題 <span class="page">4</span>
3. Kubernetesって何者？ <span class="page">5</span>
4. Kubernetesの主な機能 <span class="page">6-7</span>
5. なぜKubernetesが必要なの？ <span class="page">8</span>
6. 実際の使用例 <span class="page">9</span>
7. まとめ <span class="page">10</span>

</div>

---
<div class="header-bar">Kubernetes イントロダクション</div>

# コンテナの世界の困りごと 😫

![width:400px](https://illustimage.com/photo/illust/2023/12/01/0001.png)

<div class="problem">
❌ **困りごと1**: コンテナが増えすぎて管理が大変！
- どのコンテナがどこで動いているか把握できない
- 手動で管理するのは限界がある
</div>

<div class="problem">
❌ **困りごと2**: アプリケーションのスケールが難しい
- アクセスが増えたらどうする？
- サーバーが壊れたらどうする？
</div>

---
<div class="header-bar">Kubernetes イントロダクション</div>

# Kubernetesが解決する問題 🎯

![width:400px](https://illustimage.com/photo/illust/2023/12/01/0002.png)

<div class="solution">
✅ **解決策1**: コンテナの自動管理
- コンテナの配置を自動で最適化
- 障害が発生したら自動で復旧
</div>

<div class="solution">
✅ **解決策2**: 簡単なスケーリング
- アクセスが増えたら自動でスケールアップ
- 負荷が減ったら自動でスケールダウン
</div>

---
<div class="header-bar">Kubernetes イントロダクション</div>

# Kubernetesって何者？ 🤔

![width:400px](https://illustimage.com/photo/illust/2023/12/01/0003.png)

- ギリシャ語で「操舵手」や「水先案内人」を意味する
- コンテナの世界の船長さん！
- 略して「K8s」と呼ばれる

<div class="note">
📝 **豆知識**: 2014年にGoogleがオープンソース化し、Googleの15年以上の経験が詰まっています
</div>

---
<div class="header-bar">Kubernetes イントロダクション</div>

# Kubernetesの主な機能 (1/2) 🛠️

![width:400px](https://illustimage.com/photo/illust/2023/12/01/0004.png)

## 自動化の達人
- デプロイの自動化
- スケーリングの自動化
- 障害復旧の自動化

## 環境の違いを吸収
- クラウドでも動く
- オンプレミスでも動く

---
<div class="header-bar">Kubernetes イントロダクション</div>

# Kubernetesの主な機能 (2/2) 🛠️

![width:400px](https://illustimage.com/photo/illust/2023/12/01/0005.png)

## 宣言的な管理
- 望ましい状態を宣言するだけ
- あとはKubernetesが自動で実現

## セキュリティ
- コンテナ間の通信制御
- アクセス制御
- シークレット管理

---
<div class="header-bar">Kubernetes イントロダクション</div>

# なぜKubernetesが必要なの？ 🤷‍♂️

![width:400px](https://illustimage.com/photo/illust/2023/12/01/0006.png)

## 主な理由
1. 運用の手間を減らせる
2. アプリケーションの可用性が上がる
3. スケーリングが簡単になる

<div class="note">
💡 **開発者と運用チームの両方にメリット**:
- 開発者はアプリケーションに集中できる
- 運用チームの負担が減る
</div>

---
<div class="header-bar">Kubernetes イントロダクション</div>

# 実際の使用例 📝

![width:400px](https://illustimage.com/photo/illust/2023/12/01/0007.png)

## マイクロサービス
- 複数の小さなサービスを管理
- サービス間の連携を自動化

## 実際の企業での使用例
- Google, Amazon, Microsoft
- Spotify, Airbnb, Uber

---
<div class="header-bar">Kubernetes イントロダクション</div>

# まとめ 📚

![width:400px](https://illustimage.com/photo/illust/2023/12/01/0008.png)

## Kubernetesの3つの特徴
1. 自動化の達人
2. 環境の違いを吸収
3. 宣言的な管理

<div class="note">
💡 **次のステップ**:
- 実際のクラスターを作ってみよう
- 簡単なアプリケーションをデプロイしてみよう
</div>

---
<div class="header-bar">Kubernetes イントロダクション</div>

# ご清聴ありがとうございました 🙏

![width:300px](https://illustimage.com/photo/illust/2023/12/01/0009.png)

## 次のステップ
- 実際のクラスターを作ってみよう
- 簡単なアプリケーションをデプロイしてみよう
- スケーリングを試してみよう 
