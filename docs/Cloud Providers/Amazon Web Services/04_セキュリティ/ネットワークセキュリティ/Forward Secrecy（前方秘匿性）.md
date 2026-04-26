<!-- Space: harukaaibarapublic -->
<!-- Parent: ネットワークセキュリティ -->
<!-- Title: Forward Secrecy（前方秘匿性）とは -->

# Forward Secrecy（前方秘匿性）とは

TLS で暗号化した通信は「今は読めないが、将来は読まれるかもしれない」というリスクを持っている。

攻撃者が暗号化通信を記録・保存しておき、数年後にサーバーの秘密鍵が漏えいしたとき（不正アクセス、元従業員の退職、脆弱性による流出）、保存しておいた過去の通信をすべて復号できる。これを **「Harvest now, decrypt later（今収集して後で復号）」** と呼ぶ。量子コンピュータの実用化が近づく中、現実的な脅威として注目されている。

Forward Secrecy（前方秘匿性）は、この問題を根本から解決する仕組みだ。

## なぜ秘密鍵が漏れても過去の通信を守れるのか

通常の TLS（PFS なし）では、サーバーの長期秘密鍵からセッション鍵を直接導出する。秘密鍵が漏れれば、過去のすべての通信が復号可能になる。

Forward Secrecy では接続ごとに異なる鍵を使う。

1. クライアント・サーバーがそれぞれ使い捨ての「エフェメラル（一時）鍵」を生成
2. エフェメラル鍵を使って Diffie-Hellman 鍵交換を行い、セッション鍵を生成
3. セッション終了後、エフェメラル鍵を即座に破棄

サーバーの長期秘密鍵が後から漏れても、エフェメラル鍵はすでに存在しない。鍵がないため過去の通信は復号できない。

これを実現するのが **ECDHE**（Elliptic Curve Diffie-Hellman Ephemeral）や **DHE**（Diffie-Hellman Ephemeral）の鍵交換アルゴリズム。

## TLS 1.3 では標準、TLS 1.2 では設定次第

TLS 1.3（2018年〜）では Forward Secrecy が**必須要件**になった。PFS をサポートしない旧来の RSA 鍵交換は廃止されている。

TLS 1.2 以前では、利用する cipher suite によって PFS の有無が分かれる。

| cipher suite | 鍵交換 | PFS |
|---|---|---|
| TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 | ECDHE | あり ✓ |
| TLS_RSA_WITH_AES_256_GCM_SHA384 | RSA | なし ✗ |

cipher suite 名に `ECDHE_` または `DHE_` が含まれていれば PFS あり。

## AWS での設定確認ポイント

AWS の各サービスは TLS セキュリティポリシー（使用可能な cipher suite のセット）を選択できる。古いポリシーを使い続けると、PFS なしの cipher suite も有効なまま残る。

### ALB

`ELBSecurityPolicy-TLS13-1-2-2021-06` 以降を選択するのが現実的な基準。TLS 1.3 を含み、PFS のみの構成になる。

```bash
# セキュリティポリシーの確認
aws elbv2 describe-load-balancers --query 'LoadBalancers[*].[LoadBalancerName,DNSName]'
aws elbv2 describe-listeners --load-balancer-arn <arn> \
  --query 'Listeners[*].[Port,SslPolicy]'
```

### CloudFront

セキュリティポリシー `TLSv1.2_2021` 以降を使うと PFS 対応の cipher suite に絞られる。

```bash
aws cloudfront get-distribution-config --id <distribution-id> \
  --query 'DistributionConfig.ViewerCertificate.MinimumProtocolVersion'
```

### API Gateway（カスタムドメイン）

`TLS 1.2` ポリシーを選択することで ECDHE ベースの cipher suite に限定できる。

## 接続確認

```bash
# 接続時の cipher suite を確認
openssl s_client -connect your-alb.example.com:443 2>/dev/null | grep "Cipher"

# 例: ECDHE-RSA-AES256-GCM-SHA384 → PFS あり
#     AES256-GCM-SHA384 → PFS なし（ECDHE が付いていない）
```

出力に `ECDHE` が含まれていれば Forward Secrecy が有効。

## 参考

- [HTTPS listeners for your Application Load Balancer - AWS](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html)
- [Supported protocols and ciphers between viewers and CloudFront - AWS](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html)
- [RFC 8446 - The Transport Layer Security (TLS) Protocol Version 1.3](https://datatracker.ietf.org/doc/html/rfc8446)
