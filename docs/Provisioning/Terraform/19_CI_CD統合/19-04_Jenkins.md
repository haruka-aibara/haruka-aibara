<!-- Space: harukaaibarapublic -->
<!-- Parent: 19_CI_CD統合 -->
<!-- Title: Jenkins での Terraform -->

# Jenkins での Terraform

Jenkins パイプラインで Terraform の plan / apply を実行する構成。オンプレ環境や既存の Jenkins 環境がある場合に選択肢になる。

---

## Jenkinsfile（Declarative Pipeline）

```groovy
pipeline {
  agent {
    docker {
      image 'hashicorp/terraform:1.7.0'
      args '--entrypoint=""'
    }
  }

  environment {
    AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
    AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    AWS_DEFAULT_REGION    = 'ap-northeast-1'
  }

  stages {
    stage('Init') {
      steps {
        sh 'terraform -chdir=infra init'
      }
    }

    stage('Plan') {
      steps {
        sh 'terraform -chdir=infra plan -out=tfplan'
        archiveArtifacts artifacts: 'infra/tfplan'
      }
    }

    stage('Approve') {
      when {
        branch 'main'
      }
      steps {
        input message: 'Apply this plan?', ok: 'Apply'
      }
    }

    stage('Apply') {
      when {
        branch 'main'
      }
      steps {
        sh 'terraform -chdir=infra apply -auto-approve tfplan'
      }
    }
  }
}
```

---

## 認証情報の管理

Jenkins の Credentials（Manage Jenkins → Credentials）に保存して `credentials()` で参照する。

- AWS キーは `Secret text` 種別で登録
- SSH キーは `SSH Username with private key` で登録

環境変数に平文で書かない。

---

## Terraform プラグイン

Jenkins Marketplace に Terraform プラグインがあり、GUI 設定でバージョン管理が可能。

ただし Docker イメージで Terraform を動かす方が：
- バージョン固定が明確
- 環境差異が出にくい
- プラグインのメンテに依存しない

という理由でシンプルなケースでは Docker の方が推奨されることが多い。

---

## GitHub Actions / GitLab CI との比較

| 比較項目 | Jenkins | GitHub Actions / GitLab CI |
|---|---|---|
| セルフホスト | ✓（必須） | オプション |
| 設定コスト | 高い | 低い |
| プラグイン | 豊富 | Marketplace / Orbs |
| PR 連携 | 自前実装が必要 | 標準機能あり |

既存 Jenkins 環境があるなら活用するが、新規プロジェクトでは GitHub Actions か GitLab CI の方がラク。
