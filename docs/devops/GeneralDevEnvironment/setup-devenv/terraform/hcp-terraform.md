
以下の場合の対処法
 - Terraform Cloudを使用してインフラストラクチャを管理している。
 - コードはGitHubにバージョン管理されている。
 - 現在のインフラストラクチャリソースを一時的に削除（destroy）したい。
 - しかし、将来的に再利用できるように、コードはGitHub上に残しておきたい。

1. Terraform Cloudのワークスペースに移動します。
2. 「Settings」 > 「Destruction and Deletion」を選択します。
3. "Queue destroy plan"オプションを使用して、destroy planをキューに入れます。
