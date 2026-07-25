# virtualenv / venv

プロジェクト A は requests 2.28 が必要、B は最新が必要。システムの Python に `pip install` し続けると、この2つは同居できず、どちらかが壊れる——**プロジェクトごとに独立したパッケージ置き場**を作るのが仮想環境で、Python 開発の大前提となる作法。

## 基本操作（venv）

virtualenv はこの仕組みの元祖のサードパーティツールで、その主要機能が標準ライブラリ **venv** として取り込まれた。今は venv を使えばよい（「virtualenv」は概念名として残っている）。

```bash
python3 -m venv .venv              # プロジェクト直下に環境を作る（ディレクトリ名 .venv が慣習）
source .venv/bin/activate          # 有効化（Windows: .venv\Scripts\activate）
pip install requests               # → .venv の中にだけ入る
deactivate                         # 抜ける
```

仕組みは単純で、`.venv/` に専用の `site-packages`（パッケージ置き場）と python へのリンクを作り、activate は **PATH の先頭に `.venv/bin` を差し込むだけ**。だから activate を忘れて pip install すると、システム側に入ってしまう——「入れたはずのパッケージが ModuleNotFoundError」の最頻出原因。今どの環境にいるかは `which python` で確認できる。

`.venv/` は再生成可能なので **git には入れない**（.gitignore へ）。環境の再現は依存定義ファイル（requirements.txt 等）から行う：

```bash
pip freeze > requirements.txt      # 現環境の記録
pip install -r requirements.txt   # 別マシンでの再現
```

## なぜシステム Python に入れてはいけないのか

利便性の問題だけではない。OS 自体（apt や dnf、各種システムツール）が Python に依存しているため、**システムの site-packages を pip で書き換えると OS のツールが壊れる**ことがある。この事故が多発したため、最近の OS（Ubuntu 24.04 等）は仮想環境外での pip install を**エラーで拒否**するようになった（PEP 668、`externally-managed-environment` エラー）。「仮想環境を作るのが例外なく最初の一歩」は、いまや推奨ではなく強制になりつつある。

## 周辺ツールとの関係

- **pyenv**（[14-03](14-03_pyenv.md)）：Python 本体のバージョンを切り替える。venv は「パッケージの分離」、pyenv は「インタプリタの分離」で役割が別（併用する）
- **Pipenv**（[14-01](14-01_Pipenv.md)）や Poetry：venv 管理＋依存のロックを統合した上位ツール
- **uv**：近年登場した高速な統合ツール（venv 作成・pip・バージョン管理を1つで担い、非常に速い）。新規プロジェクトでは有力な選択肢になってきている

どのツールを使っても、下で起きていることは「プロジェクト専用の site-packages を切る」で共通。venv の仕組みを理解しておけば全部の土台になる。

## 参考

- [venv — Python 公式ドキュメント](https://docs.python.org/ja/3/library/venv.html)
- [PEP 668 – Marking Python base environments as “externally managed”](https://peps.python.org/pep-0668/)
- [uv — docs.astral.sh](https://docs.astral.sh/uv/)
