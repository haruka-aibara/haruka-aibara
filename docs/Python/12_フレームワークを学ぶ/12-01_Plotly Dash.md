# Plotly Dash入門

## 概要
Plotly Dashは、Pythonでインタラクティブなウェブアプリケーションを簡単に構築できるフレームワークです。

## 基本概念
Dashアプリケーションは、レイアウト（HTML/CSS）とコールバック（Python関数）で構成され、データ分析と可視化のためのWebアプリを作成できます。

## 環境準備

まずは必要なライブラリをインストールしましょう。以下のコマンドをターミナルやコマンドプロンプトで実行してください。

```python
pip install dash plotly pandas
```

## 基本的なDashアプリケーションの作成

最初の簡単なDashアプリケーションを作成してみましょう。以下のコードを入力して実行してみましょう。

```python
# 必要なライブラリをインポート
import dash
from dash import dcc, html
import plotly.express as px
import pandas as pd

# サンプルデータの作成
df = pd.DataFrame({
    '果物': ['りんご', 'みかん', 'バナナ', 'いちご'],
    '売上数': [20, 15, 30, 25]
})

# Dashアプリケーションの初期化
app = dash.Dash(__name__)

# アプリケーションのレイアウト設定
app.layout = html.Div([
    html.H1('基本的なDashアプリケーション'),
    html.Div('Dashを使った最初のデータ可視化アプリ'),
    
    # グラフの追加
    dcc.Graph(
        id='basic-graph',
        figure=px.bar(df, x='果物', y='売上数', title='果物別売上数')
    )
])

# アプリケーションの実行
if __name__ == '__main__':
    app.run(debug=True)
```

このコードを実行すると、ローカルのウェブサーバーが起動し、ブラウザで `http://127.0.0.1:8050/` にアクセスすることでアプリケーションが表示されます。

**実行結果:**
ブラウザでは「基本的なDashアプリケーション」というタイトルと、果物ごとの売上数を示す棒グラフが表示されます。

## インタラクティブな要素の追加

次に、ドロップダウンメニューを追加して、ユーザーがグラフの種類を選択できるようにしましょう。以下のコードを入力して実行してみましょう。

```python
# 必要なライブラリをインポート
import dash
from dash import dcc, html, callback, Input, Output
import plotly.express as px
import pandas as pd

# サンプルデータの作成
df = pd.DataFrame({
    '果物': ['りんご', 'みかん', 'バナナ', 'いちご'],
    '売上数': [20, 15, 30, 25],
    '価格': [100, 80, 120, 200]
})

# Dashアプリケーションの初期化
app = dash.Dash(__name__)

# アプリケーションのレイアウト設定
app.layout = html.Div([
    html.H1('インタラクティブなDashアプリケーション'),
    html.Div('グラフの種類を選択できます'),
    
    # ドロップダウンメニューを追加
    dcc.Dropdown(
        id='graph-type',
        options=[
            {'label': '棒グラフ', 'value': 'bar'},
            {'label': '折れ線グラフ', 'value': 'line'},
            {'label': '散布図', 'value': 'scatter'}
        ],
        value='bar'  # デフォルト値
    ),
    
    # グラフの追加
    dcc.Graph(id='interactive-graph')
])

# コールバック関数の定義
@callback(
    Output('interactive-graph', 'figure'),
    Input('graph-type', 'value')
)
def update_graph(selected_graph_type):
    # 選択されたグラフタイプに基づいてグラフを生成
    if selected_graph_type == 'bar':
        fig = px.bar(df, x='果物', y='売上数', title='果物別売上数')
    elif selected_graph_type == 'line':
        fig = px.line(df, x='果物', y='売上数', title='果物別売上数の推移')
    elif selected_graph_type == 'scatter':
        fig = px.scatter(df, x='価格', y='売上数', text='果物', 
                         title='価格と売上数の関係',
                         labels={'価格': '価格（円）', '売上数': '売上数（個）'})
    
    return fig

# アプリケーションの実行
if __name__ == '__main__':
    app.run(debug=True)
```

このコードを実行すると、ドロップダウンメニューでグラフの種類を選択できるインタラクティブなアプリケーションが表示されます。

**実行結果:**
ブラウザには、ドロップダウンメニューとグラフが表示されます。メニューで「棒グラフ」、「折れ線グラフ」、「散布図」を選択すると、それに応じてグラフの表示が変化します。

## データ入力フォームの追加

ユーザーがデータを入力できるフォームを追加しましょう。以下のコードを入力して実行してみましょう。

```python
# 必要なライブラリをインポート
import dash
from dash import dcc, html, callback, Input, Output, State
import plotly.express as px
import pandas as pd

# 初期データ
initial_data = pd.DataFrame({
    '果物': ['りんご', 'みかん', 'バナナ'],
    '売上数': [20, 15, 30]
})

# Dashアプリケーションの初期化
app = dash.Dash(__name__)

# アプリケーションのレイアウト設定
app.layout = html.Div([
    html.H1('データ入力フォーム付きDashアプリケーション'),
    
    # データ入力フォーム
    html.Div([
        html.Div([
            html.Label('果物名:'),
            dcc.Input(id='fruit-name', type='text', value='')
        ], style={'margin-right': '20px'}),
        
        html.Div([
            html.Label('売上数:'),
            dcc.Input(id='sales-count', type='number', value='')
        ], style={'margin-right': '20px'}),
        
        html.Button('追加', id='add-button', n_clicks=0)
    ], style={'display': 'flex', 'margin-bottom': '20px'}),
    
    # データテーブル
    html.Div(id='data-table'),
    
    # グラフ
    dcc.Graph(id='data-graph')
])

# グローバル変数としてデータフレームを保持
data_df = initial_data.copy()

# コールバック関数：データ追加とテーブル・グラフ更新
@callback(
    [Output('data-table', 'children'),
     Output('data-graph', 'figure'),
     Output('fruit-name', 'value'),
     Output('sales-count', 'value')],
    [Input('add-button', 'n_clicks')],
    [State('fruit-name', 'value'),
     State('sales-count', 'value')]
)
def update_data(n_clicks, fruit_name, sales_count):
    global data_df
    
    # ボタンがクリックされ、有効な入力がある場合
    if n_clicks > 0 and fruit_name and sales_count:
        # 新しいデータを追加
        new_row = pd.DataFrame({
            '果物': [fruit_name],
            '売上数': [int(sales_count)]
        })
        data_df = pd.concat([data_df, new_row], ignore_index=True)
    
    # テーブルの作成
    table = html.Table([
        html.Thead(html.Tr([html.Th('果物'), html.Th('売上数')])),
        html.Tbody([
            html.Tr([
                html.Td(data_df.iloc[i]['果物']),
                html.Td(data_df.iloc[i]['売上数'])
            ]) for i in range(len(data_df))
        ])
    ], style={'border': '1px solid black', 'margin-bottom': '20px'})
    
    # グラフの作成
    fig = px.bar(data_df, x='果物', y='売上数', title='果物別売上数')
    
    # 入力フィールドをクリア
    return table, fig, '', ''

# アプリケーションの実行
if __name__ == '__main__':
    app.run(debug=True)
```

このコードを実行すると、データを入力して追加できるフォームを持つアプリケーションが表示されます。

**実行結果:**
ブラウザには、果物名と売上数を入力するフォーム、追加ボタン、現在のデータを表示するテーブル、そしてグラフが表示されます。果物名と売上数を入力して「追加」ボタンをクリックすると、テーブルとグラフが更新されます。

## 複数のグラフを含むダッシュボード

最後に、複数のグラフを含むダッシュボードを作成してみましょう。以下のコードを入力して実行してみましょう。

```python
# 必要なライブラリをインポート
import dash
from dash import dcc, html
import plotly.express as px
import plotly.graph_objects as go
import pandas as pd
import numpy as np

# サンプルデータの作成
np.random.seed(42)
dates = pd.date_range('2023-01-01', periods=30)
sales_data = pd.DataFrame({
    '日付': dates,
    'りんご': np.random.randint(10, 50, size=30),
    'みかん': np.random.randint(5, 40, size=30),
    'バナナ': np.random.randint(15, 60, size=30),
    'いちご': np.random.randint(8, 30, size=30)
})

# 総売上データの作成
monthly_sales = sales_data.copy()
monthly_sales['月'] = monthly_sales['日付'].dt.month
monthly_sales = monthly_sales.groupby('月').sum().reset_index()
monthly_sales = monthly_sales.drop(columns=['日付'])

# 各果物の売上合計
total_by_fruit = {
    '果物': ['りんご', 'みかん', 'バナナ', 'いちご'],
    '合計売上': [
        sales_data['りんご'].sum(),
        sales_data['みかん'].sum(),
        sales_data['バナナ'].sum(),
        sales_data['いちご'].sum()
    ]
}
total_by_fruit_df = pd.DataFrame(total_by_fruit)

# Dashアプリケーションの初期化
app = dash.Dash(__name__)

# アプリケーションのレイアウト設定
app.layout = html.Div([
    html.H1('果物販売ダッシュボード'),
    html.Div('複数のグラフを含んだ総合的なダッシュボード'),
    
    # 二つのグラフを横に並べる
    html.Div([
        # 左側：日別売上の折れ線グラフ
        html.Div([
            html.H3('日別売上推移'),
            dcc.Graph(
                id='daily-sales',
                figure=px.line(
                    sales_data, 
                    x='日付', 
                    y=['りんご', 'みかん', 'バナナ', 'いちご'],
                    title='日別販売数'
                )
            )
        ], style={'width': '50%', 'display': 'inline-block'}),
        
        # 右側：果物別の総売上の円グラフ
        html.Div([
            html.H3('果物別総売上'),
            dcc.Graph(
                id='total-by-fruit',
                figure=px.pie(
                    total_by_fruit_df, 
                    values='合計売上', 
                    names='果物', 
                    title='果物別合計販売数'
                )
            )
        ], style={'width': '50%', 'display': 'inline-block'})
    ]),
    
    # 月別売上のヒートマップ
    html.Div([
        html.H3('月別果物売上ヒートマップ'),
        dcc.Graph(
            id='monthly-heatmap',
            figure=px.imshow(
                monthly_sales.set_index('月')[['りんご', 'みかん', 'バナナ', 'いちご']],
                labels=dict(x="果物", y="月", color="売上数"),
                x=['りんご', 'みかん', 'バナナ', 'いちご'],
                y=monthly_sales['月'],
                aspect="auto",
                title='月別果物販売ヒートマップ'
            )
        )
    ])
])

# アプリケーションの実行
if __name__ == '__main__':
    app.run(debug=True)
```

このコードを実行すると、複数のグラフを含む総合的なダッシュボードが表示されます。

**実行結果:**
ブラウザには、上部に日別売上推移の折れ線グラフと果物別総売上の円グラフが横に並び、下部に月別果物売上のヒートマップが表示されます。これらのグラフにより、異なる観点からデータを分析できます。

## まとめ

Plotly Dashを使うことで、Pythonだけでインタラクティブなデータ可視化アプリケーションを簡単に作成できます。本チュートリアルで学んだ内容をもとに、独自のダッシュボードを作成してみましょう。さらに高度な機能を使いたい場合は、Plotly DashとPlotlyの公式ドキュメントを参照することをお勧めします。
