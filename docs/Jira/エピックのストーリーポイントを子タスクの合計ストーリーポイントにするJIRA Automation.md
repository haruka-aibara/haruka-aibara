## サブタスクのストーリーポイントの合計をエピックに表示したかった理由

バックログでは各タスクの合計が表示されますが、エピック単位での確認が必要でした。

標準機能ではエピック単位の各タスクのストーリーポイント合計を表示する機能は見つからなかったため、JIRA Automationを利用して実現できそうだと考え、調査・実装した。

## 成功した手法

参考記事:

https://community.atlassian.com/t5/Automation-questions/How-sum-up-story-point-estimate-in-Epic-from-stories-and-others/qaq-p/2204699

1. ルールを作成
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-20.png>)

2. フィールド値の変更時
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-21.png>)

3. 変化を監視するためのフィールド - Story point estimate
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-22.png>)

4. 次へ
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-23.png>)

5. IF: 条件を追加
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-24.png>)

6. 課題フィールドの条件
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-25.png>)

7. フィールド: 課題タイプ 条件: と等しい 値: タスク
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-26.png>)

8. 次へ
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-27.png>)

9. その場合: アクションを追加する
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-28.png>)

10. 課題を検索
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-29.png>)

11. JQL - project = yourProjectName AND parent = {{triggerIssue.parent.key}}
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-30.png>)

12. 次へ
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-31.png>)

13. FOR EACH: ブランチを追加
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-32.png>)

14. ルール/関連する課題を分割する
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-33.png>)

15. 関連課題のタイプ - 親
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-34.png>)

16. 次へ
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-35.png>)

17. その場合、アクションを追加する
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-36.png>)

18. 課題の編集
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-37.png>)

19. その他オプション - 「このルールはメールを～」のチェックを外し、追加フィールドを下記の JSON を入力する
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-38.png>)

```json
{
  "fields": {
   "Story point estimate": {{lookupIssues.Story point estimate.sum|0}}
  }
}
```

20. 次へ
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-39.png>)

21. ルールをオンにする
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-40.png>)

22. 任意のルール名を入力する（ここでは「見積自動更新」としました。）
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-41.png>)

23. ルールをオンにしたら完了です。
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-42.png>)


後はエピックの Story point estimate に子タスクの合計ストーリーポイントが表示されます。

![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-43.png>)


## 備忘のため、過去の失敗した履歴を下記に残しておきます。

失敗した理由：

JIRAには、チーム管理対象プロジェクトと企業管理対象プロジェクトの2種類があります。私が使用していたのは、チーム管理対象プロジェクトでした。

当初、自動化の実現を目指して「Story Points」フィールドを使用する方法を見つけ下記の通り試しましたが、このフィールドは企業管理対象プロジェクトにしか存在せず、実現できませんでした。

しかし、その後、チーム管理対象プロジェクトに存在する「Story point estimate」フィールドを活用することで、先述の「成功した手法」で実現することができました。

JIRAのプロジェクトタイプについての詳細は、以下のAtlassianサポートページでご確認いただけます：

https://support.atlassian.com/ja/jira-software-cloud/docs/what-are-team-managed-and-company-managed-projects/

### 失敗した手順
JIRA Automation を使います。

備忘のための記録として、画像と簡単なメモだけ貼付していきます。

最後までやった結果、Story Points というフィールドがなく実現できていない。

参考記事

https://www.ricksoft.jp/blog/articles/001550.html

1. ツアーをスキップ

![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image.png>)

2. フィールド値の変更時

![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-1.png>)

3. Story Points
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-2.png>)

4. 次へ
![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-3.png>)


![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-4.png>)


![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-5.png>)

![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-6.png>)

![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-7.png>)

![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-8.png>)

![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-9.png>)

![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-10.png>)

![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-11.png>)

![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-12.png>)

![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-13.png>)

![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-14.png>)

![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-15.png>)

![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-16.png>)

![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-17.png>)

![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-18.png>)

![alt text](<assets/エピックのストーリーポイントを子タスクの合計ストーリーポイントにするJIRA Automation/image-19.png>)
