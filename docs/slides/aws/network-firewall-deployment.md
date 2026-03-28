---
marp: true
theme: default
paginate: true
---

# AWS Network Firewall
## デプロイパターン：分散 vs 集約

---
test
## なぜ迷うのか

AWS Network Firewall を入れようとすると最初に問われる。

> **「どこに置くか」**

- 各 VPC に個別に置く（**分散**）
- 中央の Inspection VPC に集めて TGW で通す（**集約**）

選択を間違えると
コスト爆発 or TGW 設定ミスで非対称ルーティングでハマる

---

## 分散デプロイ

各 VPC に Firewall エンドポイントを配置

```
[Internet Gateway]
        ↓  (IGW ルートテーブル: Ingress Routing)
[Firewall Subnet] ← Network Firewall Endpoint
        ↓
[Application Subnet]
```

⚠️ **IGW Ingress Routing を忘れると非対称ルーティングになる**

---

## 分散デプロイ：特徴

| | |
|---|---|
| **向いている** | VPC が少ない / TGW 未使用 / VPC ごとに独立したポリシーが必要 |
| **コスト** | Endpoint 約 $0.395/時 × VPC 数 × AZ 数 |
| **障害影響** | 1 VPC に閉じる |
| **East-West 検査** | ✗ できない |

**サブネット設計**: Firewall サブネットは /28 で十分、AZ をまたがないこと

---

## 集約デプロイ

専用の Inspection VPC に集約、TGW 経由でルーティング

```
[Spoke VPC A] ──┐
[Spoke VPC B] ──┼──→ [TGW] ──→ [Inspection VPC]
[Spoke VPC C] ──┘              [Network Firewall]
                                       ↓
                              [Egress VPC / IGW]
```

---

## 集約デプロイ：TGW Appliance Mode が必須

⚠️ **これを忘れると検査が機能しない**

Appliance Mode = OFF の場合
→ 戻りパケットが**別の AZ の Firewall エンドポイント**を通る
→ ステートフルルールがセッションを追えずドロップ

```
TGW アタッチメント設定:
ApplianceModeSupport: enable  ← これ
```

---

## 集約デプロイ：特徴

| | |
|---|---|
| **向いている** | VPC が多い / マルチアカウント / East-West 検査が必要 |
| **コスト** | Firewall Endpoint は Inspection VPC の AZ 数だけ |
| **障害影響** | Inspection VPC が落ちると全体に影響（AZ 分散で軽減） |
| **East-West 検査** | ✅ できる |
| **注意** | TGW 料金が追加される |

---

## 分散 vs 集約 比較

| 観点 | 分散 | 集約 |
|---|---|---|
| コスト | VPC 数に比例して増加 | TGW 追加だが VPC 多いと安い |
| 管理 | VPC ごとに設定 | 中央管理（Firewall Manager ◎） |
| レイテンシ | 低い | TGW 分だけ増加（通常 ms 以下） |
| East-West 検査 | ✗ | ✅ |
| よくある設定ミス | IGW Ingress Routing 忘れ | TGW Appliance Mode 忘れ |

---

## GWLB との使い分け

| | Network Firewall | GWLB + サードパーティ |
|---|---|---|
| 運用 | AWS マネージド | Appliance の OS・パッチ管理が必要 |
| 機能 | Suricata ルール + TLS Inspection | ベンダー製品の全機能 |
| 選ぶなら | AWS ネイティブで完結させたい | Palo Alto・Fortinet を既存で持っている |

---

## Firewall Manager との組み合わせ

集約デプロイ × Firewall Manager でマルチアカウント管理

```
AWS Organizations
└── Firewall Manager（管理アカウント）
    └── Policy: 新しいアカウントに自動で Network Firewall をデプロイ
```

「アカウントを作ったのにファイアウォール設定し忘れた」を防げる

---

## どのパターンを選ぶか

```
VPC が 5 以下、TGW 未使用
  → 分散デプロイ

VPC が多い or マルチアカウント
  → 集約デプロイ + Firewall Manager

East-West と North-South を独立して制御したい
  → コンバインド（設計は複雑になる）

既存の商用 Appliance を使いたい
  → GWLB + サードパーティ製品
```

---

## まとめ

「集約の方がプロっぽい」は**半分正しくて半分間違い**

- 大規模・マルチアカウント → 集約が正解
- 小規模で無理に集約 → TGW 設定ミスと複雑なルート設計で運用コスト増

**どちらを選んでもハマりポイントは必ずある**
→ 事前に設定ミスのパターンを知っておくこと
