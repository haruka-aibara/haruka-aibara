# setuptools でテスト（python setup.py test）— 廃止済み

古い Python プロジェクトの README や CI 設定で `python setup.py test` という起動方法を見かけることがある。**これは廃止済みの作法**で、新規に使うことはない。ただし古いリポジトリの保守や CI の移行では出くわすので、「何だったのか」「今は何に置き換えるか」だけ押さえておく。

## 何だったのか

setuptools（パッケージング用ライブラリ）には、かつて `test` コマンドがあり、`setup.py` にテスト設定を書くと `python setup.py test` で「依存を解決してテスト実行」までやってくれた。パッケージングとテスト起動が一体化していた時代の仕組み。

```python
# 昔の setup.py（現在は非推奨）
setup(
    ...
    test_suite="tests",
    tests_require=["pytest"],
)
```

setuptools 自体の方針転換（「ビルドツールに徹し、テストランナーはやらない」）により deprecated → 削除の道を辿った。`setup.py` を直接コマンドとして叩く文化自体が widely deprecated で、テストに限らず `setup.py install` 等も同様に過去のものになっている。

## 今は何を使うか

役割は分業に置き換わった：

- **テストランナー** → pytest（[18-05](18-05_pytest.md)）を直接叩く。`pytest` の一言でよい
- **複数環境・分離環境でのテスト** → tox（[18-01](18-01_tox.md)）や nox。`setup.py test` が担っていた「依存を入れてからテスト」はこちらの仕事
- **設定の置き場** → `setup.py` ではなく `pyproject.toml`（pytest の設定も `[tool.pytest.ini_options]` に書ける）

古いプロジェクトを移行するときの作業は、おおむね「`setup.py` の test 関連設定を削除 → `pyproject.toml` に pytest 設定を移す → CI の `python setup.py test` を `pytest` に書き換える」の3手で終わる。実際の OSS でもこの移行 PR は大量に存在する（当時のメモ: [mwclient の例](https://github.com/mwclient/mwclient/pull/356)）。

## 参考

- [setup.py deprecated? — Python Packaging User Guide](https://packaging.python.org/en/latest/discussions/setup-py-deprecated/)
- [pyproject.toml — pytest documentation](https://docs.pytest.org/en/stable/reference/customize.html)
