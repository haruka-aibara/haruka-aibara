# Kubernetes講義: PVとPVC

## 概要

PV（Persistent Volume）とPVC（Persistent Volume Claim）はKubernetesでデータを永続化するための仕組みで、アプリケーションとストレージを分離する重要な概念です。

## 基本概念

PVとPVCはストレージのプロビジョニングと消費を分離するKubernetesリソースで、それぞれインフラ管理者とアプリケーション開発者の責任領域を明確にします。

## PV（Persistent Volume）

### 定義
PVはクラスター内で利用可能なストレージリソースを表す物理的なストレージの抽象化です。

### 特徴
- クラスター管理者によって事前にプロビジョニングされる
- ポッドとは独立したライフサイクルを持つ
- 様々なストレージタイプ（NFS、AWS EBS、GCE PD、AzureDiskなど）をサポート

### 主要な設定項目
- `capacity`: ストレージの容量
- `accessModes`: 読み書きのアクセス権限（ReadWriteOnce、ReadOnlyMany、ReadWriteMany）
- `persistentVolumeReclaimPolicy`: PVが解放された後の処理方法（Retain、Delete、Recycle）
- `storageClassName`: どのStorageClassに属するかを指定

### サンプル
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: example-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  hostPath:
    path: /mnt/data
```

## PVC（Persistent Volume Claim）

### 定義
PVCはアプリケーションがストレージを要求するための抽象化で、ポッドがPVを使用するためのリクエストです。

### 特徴
- 開発者によって作成される
- 必要なストレージの特性（サイズ、アクセスモードなど）を指定
- 適切なPVとバインドされる
- ポッドから参照されてストレージを利用

### 主要な設定項目
- `accessModes`: 必要なアクセスモード
- `resources`: 要求するリソース量（ストレージ容量など）
- `storageClassName`: 使用するStorageClassの指定
- `selector`: 特定のラベルを持つPVを選択するための条件

### サンプル
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: example-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: standard
```

## PVとPVCのバインディング

1. PVCが作成されると、Kubernetesコントローラーは要求を満たすPVを探す
2. 適切なPVが見つかると、PVCとPVがバインドされる
3. バインドされたPVは他のPVCでは使用できない
4. PVCはポッドのボリュームとして指定される

### ポッドからPVCを使用する例
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: example-pod
spec:
  containers:
    - name: app
      image: nginx
      volumeMounts:
        - mountPath: "/var/www/html"
          name: app-data
  volumes:
    - name: app-data
      persistentVolumeClaim:
        claimName: example-pvc
```

## StorageClass

StorageClassはPVを動的にプロビジョニングするための仕組みを提供します。

### 特徴
- PVの手動作成を不要にする
- ストレージの種類やパラメータを定義
- PVCからStorageClassを指定して動的にPVを作成

### サンプル
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Delete
allowVolumeExpansion: true
```

## まとめ

- PVはクラスター内の物理ストレージを抽象化したリソース
- PVCはアプリケーションがストレージを要求するためのリソース
- PVとPVCのバインディングによってストレージの分離と管理が実現
- StorageClassを使用すると動的なPVプロビジョニングが可能
