HCP Terraform ↔ Google Cloud を連携後、初めてお試しプロジェクトを Apply してみたところ以下エラーが出ました。

```
googleapi: Error 403: Cloud Resource Manager API has not been used in project XXXXXXXXX before or it is disabled
```

私はコンソールから有効化（下記参照）しましたが、他にも有効化する方法自体はあるようです。

https://dev.classmethod.jp/articles/google-cloud-platform-terraform-project_services/

# エラーの意味

このエラーは **「Cloud Resource Manager API がプロジェクトで有効化されていない」** という意味です。

## 原因

Google Cloud のプロジェクトで、Cloud Resource Manager API を使用しようとしているが、そのAPIが有効化されていないためです。

## 解決方法
### 1. **Google Cloud Console から有効化**
1. [Google Cloud Console](https://console.cloud.google.com/) にアクセス
2. 該当するプロジェクトを選択
3. 「APIとサービス」→「ライブラリ」を開く
4. 「Cloud Resource Manager API」を検索
5. 「有効にする」をクリック

![alt text](assets/md-image.png)