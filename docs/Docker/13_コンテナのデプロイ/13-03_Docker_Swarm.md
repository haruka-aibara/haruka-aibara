# Docker Swarm

「compose は書ける。でも Kubernetes は重すぎる。ホスト2〜3台でコンテナを冗長化したいだけなんだが」——そのニッチにちょうどはまるのが Docker Swarm。Docker に**組み込みで付いてくる**オーケストレータで、追加インストールなしに複数ホストのクラスタが組める。

## 何ができるか

```bash
docker swarm init                          # 1台目（マネージャ）
docker swarm join --token <...> <IP>:2377  # 2台目以降を参加させる
docker stack deploy -c compose.yml myapp   # compose ファイルでクラスタにデプロイ
```

これだけで：

- **compose ファイルがほぼそのまま使える**（`deploy:` セクションでレプリカ数等を指定）
- レプリカ維持・ノード障害時の再配置・ローリングアップデート
- ノード間のオーバーレイネットワークと負荷分散（routing mesh）
- secret 管理（`docker secret`）

学習コストが「Docker を知っていれば数時間」レベルなのが最大の美点で、Kubernetes の語彙・エコシステムを丸ごと学ぶ必要がない。

## 現在地：選ばれにくいが、知る価値はある

正直な現状として、オーケストレーション競争は Kubernetes が制し、Swarm は新規採用が少ない。マネージドサービス（EKS/GKE のような「マネージド Swarm」）が存在せず、エコシステム（Helm 相当、オペレータ、コミュニティ）も薄い。新規の本格運用でこれを選ぶ積極的理由は今は少ない。

それでも押さえておく理由：

- **オンプレ・エッジの小規模クラスタ**では現役の選択肢（数台のサーバーで冗長化したい、Kubernetes 運用者がいない現場）
- **オーケストレーションの概念学習**として最短：レプリカ、望ましい状態への収束、ローリングアップデートといった概念を、compose の知識の延長で体感できる。ここで掴んだ概念は Kubernetes にそのまま持っていける

## 判断の整理

- 1台で足りる → compose
- 数台・シンプルに冗長化・学習コスト最小 → Swarm は今も合理的
- クラウド・チーム開発・長期運用 → ECS か Kubernetes（[13-02](13-02_Kubernetes.md)）へ

## 参考

- [Swarm mode overview — Docker Docs](https://docs.docker.com/engine/swarm/)
- [docker stack deploy — Docker Docs](https://docs.docker.com/reference/cli/docker/stack/deploy/)
