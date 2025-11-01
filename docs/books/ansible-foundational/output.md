---
title: "Ansible出力結果の見方"
slug: "output"
---

# Ansible出力結果の見方

## 概要
Ansibleの出力結果を正しく解釈することで、自動化タスクの成功や失敗を適切に判断できます。

## 出力セクションの基本構造
Ansible実行時の出力は主に3つのセクションで構成されています：

### 1. PLAY セクション
このセクションでは、どのターゲットホストに対してplaybookが実行されるかが表示されます。ここでターゲット指定に誤りがないかを確認できます。

例：
```
PLAY [webservers] *****************************************************
```

### 2. TASK セクション
各タスクの実行結果が表示されます。タスク名とその実行結果がターゲットごとに出力されます。

例：
```
TASK [Install the latest version of httpd] ***************************
#実行結果メッセージ##
changed: [server-1]
#実行結果メッセージ##
changed: [server-2]
```

タスク実行時の主なステータス：
- `ok`: 正常に終了（変更なし）
- `changed`: 正常に終了（変更あり）
- `skipped`: タスクを実行しなかった
- `failed`: エラーが発生した

### 3. PLAY RECAP セクション
Playbook全体の実行結果サマリーが表示されます。

例：
```
PLAY RECAP *********************************************************
server-1 : ok=1 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
server-2 : ok=1 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

各項目の意味：
- `ok`: 正常終了したタスク数
- `changed`: 変更を加えたタスク数
- `unreachable`: 通信エラーが発生したタスク数
- `failed`: エラーが発生したタスク数
- `skipped`: 実行しなかったタスク数
- `rescued`: rescueディレクティブを実行したタスク数
- `ignored`: エラーが発生したが無視したタスク数

## ヒント
- `changed=0`の場合は、すでに目的の状態が達成されていることを示します
- `failed`や`unreachable`の値が0以外の場合は、問題が発生しているので詳細を確認しましょう

