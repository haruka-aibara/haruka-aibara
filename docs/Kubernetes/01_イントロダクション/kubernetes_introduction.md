---
marp: true
theme: freud
---
<div class="header-bar">Kubernetes イントロダクション</div>

<div class="cover">

# Kubernetesって何？ 🚢

<div class="subtitle">
コンテナの世界の船長さん！
</div>

![width:450px](https://illustimage.com/photo/illust/2023/12/01/cover.png)

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

![width:450px](https://illustimage.com/photo/illust/2023/12/01/0001.png)

<div class="problem">
❌ **困りごと1**: コンテナが増えすぎて管理が大変！
- どのコンテナがどこで動いているか把握できない
- 手動で管理するのは限界がある
- コンテナ間の連携が複雑
</div>

<div class="problem">
❌ **困りごと2**: アプリケーションのスケールが難しい
- アクセスが増えたらどうする？
- サーバーが壊れたらどうする？
- 負荷分散をどうする？
</div>

---
<div class="header-bar">Kubernetes イントロダクション</div>

# Kubernetesが解決する問題 🎯

![width:450px](https://illustimage.com/photo/illust/2023/12/01/0002.png)

<div class="solution">
✅ **解決策1**: コンテナの自動管理
- コンテナの配置を自動で最適化
- 障害が発生したら自動で復旧
- コンテナ間の通信を自動制御
</div>

<div class="solution">
✅ **解決策2**: 簡単なスケーリング
- アクセスが増えたら自動でスケールアップ
- 負荷が減ったら自動でスケールダウン
- リソース使用率の最適化
</div>

---
<div class="header-bar">Kubernetes イントロダクション</div>

# Kubernetesって何者？ 🤔

![width:450px](https://illustimage.com/photo/illust/2023/12/01/0003.png)

- ギリシャ語で「操舵手」や「水先案内人」を意味する
- コンテナの世界の船長さん！
- 略して「K8s」と呼ばれる（Kとsの間の8文字を数えて）

<div class="note">
📝 **豆知識**: 
- 2014年にGoogleがオープンソース化
- Googleの15年以上の経験が詰まっている
- 現在はCloud Native Computing Foundation (CNCF)が管理
</div>

---
<div class="header-bar">Kubernetes イントロダクション</div>

# Kubernetesの主な機能 (1/2) 🛠️

![width:450px](https://illustimage.com/photo/illust/2023/12/01/0004.png)

<div class="feature-grid">
<div class="feature-item">
<h3>自動化の達人</h3>
- デプロイの自動化
- スケーリングの自動化
- 障害復旧の自動化
- ロールバックの自動化
</div>

<div class="feature-item">
<h3>環境の違いを吸収</h3>
- クラウドでも動く
- オンプレミスでも動く
- ハイブリッド環境でも動く
- 環境に依存しない
</div>
</div>

---
<div class="header-bar">Kubernetes イントロダクション</div>

# Kubernetesの主な機能 (2/2) 🛠️

![width:450px](https://illustimage.com/photo/illust/2023/12/01/0005.png)

<div class="feature-grid">
<div class="feature-item">
<h3>宣言的な管理</h3>
- 望ましい状態を宣言するだけ
- あとはKubernetesが自動で実現
- 設定のバージョン管理が容易
- インフラのコード化が可能
</div>

<div class="feature-item">
<h3>セキュリティ</h3>
- コンテナ間の通信制御
- アクセス制御
- シークレット管理
- ネットワークポリシー
</div>
</div>

---
<div class="header-bar">Kubernetes イントロダクション</div>

# なぜKubernetesが必要なの？ 🤷‍♂️

![width:450px](https://illustimage.com/photo/illust/2023/12/01/0006.png)

## 主な理由
1. 運用の手間を減らせる
2. アプリケーションの可用性が上がる
3. スケーリングが簡単になる
4. インフラの抽象化ができる
5. リソース使用率が最適化される

<div class="note">
💡 **開発者と運用チームの両方にメリット**:
- 開発者はアプリケーションに集中できる
- 運用チームの負担が減る
- チーム間の協業がスムーズに
</div>

---
<div class="header-bar">Kubernetes イントロダクション</div>

# 実際の使用例 (1/2) 📝

![width:450px](https://illustimage.com/photo/illust/2023/12/01/0007.png)

## マイクロサービス
- 複数の小さなサービスを管理
- サービス間の連携を自動化
- 独立したデプロイが可能

## グローバル企業での活用
<div class="feature-grid">
<div class="feature-item">
- **Google**: 自社サービスの基盤
- **Amazon**: AWSのサービス（EKS）
</div>
<div class="feature-item">
- **Microsoft**: Azureのサービス（AKS）
- **Spotify**: マイクロサービス基盤
</div>
</div>

<div class="note">
💡 **採用の主な理由**:
- スケーラビリティの確保
- 運用コストの削減
</div>

---
<div class="header-bar">Kubernetes イントロダクション</div>

# 実際の使用例 (2/2) 📝

![width:450px](https://illustimage.com/photo/illust/2023/12/01/0007.png)

## 国内企業での活用
<div class="feature-grid">
<div class="feature-item">
- **メルカリ**: クラウドネイティブ化
- **LINE**: メッセージング基盤
</div>
<div class="feature-item">
- **サイバーエージェント**: 広告配信システム
- **楽天**: クラウドサービス基盤
</div>
</div>

## 具体的なメリット
- 開発効率の向上
- インフラの標準化
- 運用の自動化
- スケーリングの容易さ

<div class="note">
💡 **導入のポイント**:
- 段階的な移行が重要
- チームの学習コストを考慮
- 適切なサポート体制の構築
</div>

---
<div class="header-bar">Kubernetes イントロダクション</div>

# まとめ 📚

![width:450px](https://illustimage.com/photo/illust/2023/12/01/0008.png)

## Kubernetesの3つの特徴
1. 自動化の達人
2. 環境の違いを吸収
3. 宣言的な管理

<div class="note">
💡 **次のステップ**:
- 実際のクラスターを作ってみよう
- 簡単なアプリケーションをデプロイしてみよう
- スケーリングを試してみよう
- 障害復旧を体験してみよう
</div>

---
<div class="header-bar">Kubernetes イントロダクション</div>

# ご清聴ありがとうございました 🙏

![width:350px](https://illustimage.com/photo/illust/2023/12/01/0009.png)

## 次のステップ
- 実際のクラスターを作ってみよう
- 簡単なアプリケーションをデプロイしてみよう
- スケーリングを試してみよう
- 障害復旧を体験してみよう

<div class="note">
💡 **質問やディスカッションの時間**:
- 気になる点はありますか？
- 実際に試してみたいことはありますか？
</div>
