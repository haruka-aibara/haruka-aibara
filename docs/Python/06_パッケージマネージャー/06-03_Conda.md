# Python講義：Conda入門

## 概要
Condaは、Pythonのパッケージ管理と環境管理を同時に行える強力なツールです。

## 主要概念
Condaを使うと、プロジェクトごとに独立した環境を作成し、異なるバージョンのPythonやパッケージを簡単に管理できます。

## Condaの基本的な使い方

### 1. Condaのインストール

Condaを使うには、まず[Anaconda](https://www.anaconda.com/download/)または[Miniconda](https://docs.conda.io/en/latest/miniconda.html)をインストールする必要があります。インストール後、コマンドプロンプトやターミナルで以下のコマンドを実行してCondaが正しくインストールされているか確認しましょう。

```python
conda --version
```

以下のような出力が表示されます：
```
conda 23.9.0
```

### 2. Conda環境の作成

プロジェクト専用の環境を作成しましょう。次のコマンドを入力して実行してみましょう：

```python
conda create --name myenv python=3.10
```

このコマンドを実行すると、Python 3.10がインストールされた「myenv」という名前の環境が作成されます。コマンド実行時に確認メッセージが表示されるので「y」を入力してEnterキーを押します。

出力例：
```
Collecting package metadata (current_repodata.json): done
Solving environment: done

## Package Plan ##

  environment location: /Users/username/anaconda3/envs/myenv

  added / updated specs:
    - python=3.10

...

Proceed ([y]/n)? y

...

Preparing transaction: done
Verifying transaction: done
Executing transaction: done
#
# To activate this environment, use
#
#     $ conda activate myenv
#
# To deactivate an active environment, use
#
#     $ conda deactivate
```

### 3. Conda環境の有効化と無効化

作成した環境を有効化するには、以下のコマンドを入力して実行してみましょう：

```python
conda activate myenv
```

コマンドプロンプトやターミナルの表示が変わり、環境名が前に表示されます：
```
(myenv) $
```

環境を無効化するには、以下のコマンドを入力して実行してみましょう：

```python
conda deactivate
```

環境名の表示が消えます。

### 4. パッケージのインストール

環境を有効化した状態で、必要なパッケージをインストールできます。例えば、NumPyとPandasをインストールするには、以下のコマンドを入力して実行してみましょう：

```python
conda install numpy pandas
```

実行すると、パッケージとその依存関係がインストールされます。確認メッセージが表示されたら「y」を入力してEnterキーを押します。

出力例：
```
Collecting package metadata (current_repodata.json): done
Solving environment: done

## Package Plan ##

  environment location: /Users/username/anaconda3/envs/myenv

  added / updated specs:
    - numpy
    - pandas

...

Proceed ([y]/n)? y

...

Preparing transaction: done
Verifying transaction: done
Executing transaction: done
```

### 5. インストール済みパッケージの確認

環境にインストールされているパッケージを確認するには、以下のコマンドを入力して実行してみましょう：

```python
conda list
```

インストールされているパッケージの一覧が表示されます：

```
# packages in environment at /Users/username/anaconda3/envs/myenv:
#
# Name                    Version                   Build  Channel
numpy                     1.24.3           py310h2db3ef0_0    
pandas                    2.0.3            py310h2b8c604_0    
python                    3.10.13              h5ee71fb_0
...
```

### 6. 環境の一覧表示

作成したすべての環境を確認するには、以下のコマンドを入力して実行してみましょう：

```python
conda env list
```

次のような出力が表示されます：

```
# conda environments:
#
base                  *  /Users/username/anaconda3
myenv                    /Users/username/anaconda3/envs/myenv
```

アスタリスク（*）は現在有効な環境を示しています。

### 7. 環境のエクスポートと共有

作成した環境の構成を他の人と共有したり、別のマシンで再現したりするには、環境ファイルをエクスポートします。以下のコマンドを入力して実行してみましょう：

```python
conda activate myenv
conda env export > environment.yml
```

生成された「environment.yml」ファイルには、環境の詳細とインストールされたすべてのパッケージが含まれています。

### 8. 環境ファイルからの環境作成

環境ファイルを使って新しい環境を作成するには、以下のコマンドを入力して実行してみましょう：

```python
conda env create -f environment.yml
```

このコマンドにより、ファイルに記述された通りの環境が作成されます。

### 9. 環境の削除

不要になった環境を削除するには、以下のコマンドを入力して実行してみましょう：

```python
conda env remove --name myenv
```

環境「myenv」とそこにインストールされたすべてのパッケージが削除されます。

## まとめ

Condaを使うことで、プロジェクトごとに独立した環境を簡単に作成・管理できます。環境を切り替えることで、異なるバージョンのPythonやパッケージを使い分けることができ、依存関係の衝突を避けることができます。
