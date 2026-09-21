# Pythonのdocstring書き方ガイド

## 概要

Pythonのdocstringはコードの文書化に不可欠で、関数やクラスの目的や使用方法を明確に伝えます。

## 主要概念

docstringはPythonコードに組み込まれる文書化の手法で、三重引用符(`"""` または `'''`)で囲まれたテキストブロックです。

## docstringの主要スタイル

Pythonでは主に3つのdocstringスタイルが使われています。それぞれの特徴と書き方を見ていきましょう。

### 1. reStructuredText（reST）スタイル

reStructuredTextはPythonの公式ドキュメント生成ツールSphinxの標準フォーマットです。

```python
def calculate_area(radius):
    """円の面積を計算します。

    :param radius: 円の半径
    :type radius: float
    :returns: 円の面積
    :rtype: float
    :raises ValueError: 半径が負の値の場合

    """
    if radius < 0:
        raise ValueError("半径は正の値である必要があります")
    return 3.14159 * radius ** 2
```

**このコードを入力して実行してみましょう**

```python
# コードを実行
print(calculate_area(5))
print(help(calculate_area))  # docstringを表示

# エラーケースの確認
try:
    calculate_area(-1)
except ValueError as e:
    print(f"エラー: {e}")
```

**実行結果**

```
78.53975
Help on function calculate_area in module __main__:

calculate_area(radius)
    円の面積を計算します。
    
    :param radius: 円の半径
    :type radius: float
    :returns: 円の面積
    :rtype: float
    :raises ValueError: 半径が負の値の場合

エラー: 半径は正の値である必要があります
```

reSTスタイルでは、`:param:`, `:type:`, `:returns:`, `:rtype:`, `:raises:` などのフィールドを使用して情報を整理します。

### 2. NumPyスタイル

NumPyスタイルはより詳細な説明が可能で、科学計算のプロジェクトで広く使われています。

```python
def calculate_distance(point1, point2):
    """2点間のユークリッド距離を計算します。

    Parameters
    ----------
    point1 : tuple
        (x, y) 形式の1つ目の点の座標
    point2 : tuple
        (x, y) 形式の2つ目の点の座標

    Returns
    -------
    float
        2点間のユークリッド距離

    Examples
    --------
    >>> calculate_distance((0, 0), (3, 4))
    5.0
    
    Notes
    -----
    距離はピタゴラスの定理を使って計算されます。
    """
    x1, y1 = point1
    x2, y2 = point2
    return ((x2 - x1) ** 2 + (y2 - y1) ** 2) ** 0.5
```

**このコードを入力して実行してみましょう**

```python
# コードを実行
print(calculate_distance((0, 0), (3, 4)))
print(help(calculate_distance))  # docstringを表示
```

**実行結果**

```
5.0
Help on function calculate_distance in module __main__:

calculate_distance(point1, point2)
    2点間のユークリッド距離を計算します。
    
    Parameters
    ----------
    point1 : tuple
        (x, y) 形式の1つ目の点の座標
    point2 : tuple
        (x, y) 形式の2つ目の点の座標
    
    Returns
    -------
    float
        2点間のユークリッド距離
    
    Examples
    --------
    >>> calculate_distance((0, 0), (3, 4))
    5.0
    
    Notes
    -----
    距離はピタゴラスの定理を使って計算されます。
```

NumPyスタイルは「Parameters」「Returns」「Examples」などのセクションを使って構造化されており、読みやすさに優れています。

### 3. Googleスタイル

Googleスタイルは直感的で読みやすく、多くの開発者に好まれています。

```python
def sort_list(numbers, reverse=False):
    """リストを昇順または降順にソートします。
    
    Args:
        numbers (list): ソートする数値のリスト
        reverse (bool, optional): Trueなら降順、Falseなら昇順。デフォルトはFalse。
    
    Returns:
        list: ソートされたリスト
    
    Raises:
        TypeError: numbersがリストでない場合
    
    Examples:
        >>> sort_list([3, 1, 4, 1, 5])
        [1, 1, 3, 4, 5]
        >>> sort_list([3, 1, 4, 1, 5], reverse=True)
        [5, 4, 3, 1, 1]
    """
    if not isinstance(numbers, list):
        raise TypeError("入力はリストである必要があります")
    return sorted(numbers, reverse=reverse)
```

**このコードを入力して実行してみましょう**

```python
# コードを実行
print(sort_list([3, 1, 4, 1, 5]))
print(sort_list([3, 1, 4, 1, 5], reverse=True))
print(help(sort_list))  # docstringを表示

# エラーケースの確認
try:
    sort_list("これはリストではありません")
except TypeError as e:
    print(f"エラー: {e}")
```

**実行結果**

```
[1, 1, 3, 4, 5]
[5, 4, 3, 1, 1]
Help on function sort_list in module __main__:

sort_list(numbers, reverse=False)
    リストを昇順または降順にソートします。
    
    Args:
        numbers (list): ソートする数値のリスト
        reverse (bool, optional): Trueなら降順、Falseなら昇順。デフォルトはFalse。
    
    Returns:
        list: ソートされたリスト
    
    Raises:
        TypeError: numbersがリストでない場合
    
    Examples:
        >>> sort_list([3, 1, 4, 1, 5])
        [1, 1, 3, 4, 5]
        >>> sort_list([3, 1, 4, 1, 5], reverse=True)
        [5, 4, 3, 1, 1]

エラー: 入力はリストである必要があります
```

Googleスタイルは「Args」「Returns」「Raises」「Examples」などのセクションを使用し、簡潔かつ必要な情報を網羅しています。

## まとめ

各スタイルには特徴があり、プロジェクトやチームの方針に合わせて選択するとよいでしょう。
- **reSTスタイル**: Sphinxとの統合に優れ、公式ドキュメントに適しています
- **NumPyスタイル**: 科学計算分野で人気があり、詳細な説明に向いています
- **Googleスタイル**: シンプルで読みやすく、多くのプロジェクトで採用されています

どのスタイルを選んでも、一貫性を保つことが重要です。チームやプロジェクト内で統一したスタイルを使用すると、コードの可読性と保守性が向上します。
