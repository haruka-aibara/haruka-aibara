# タスクトレイに常駐しながら処理を実行するPowerShellスクリプト

# 必要なアセンブリを読み込む
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# メインアプリケーションフォームを作成（非表示）
$form = New-Object System.Windows.Forms.Form
$form.WindowState = [System.Windows.Forms.FormWindowState]::Minimized
$form.ShowInTaskbar = $false
$form.Width = 0
$form.Height = 0

# NotifyIconコンポーネントの作成とセットアップ
$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Icon = [System.Drawing.SystemIcons]::Application
$notifyIcon.Text = "タスクトレイ常駐スクリプト"
$notifyIcon.Visible = $true

# コンテキストメニューの作成
$contextMenu = New-Object System.Windows.Forms.ContextMenuStrip

# ステータス表示用のメニューアイテム
$statusMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$statusMenuItem.Text = "ステータス: 実行中"
$contextMenu.Items.Add($statusMenuItem)

# セパレーター
$separator = New-Object System.Windows.Forms.ToolStripSeparator
$contextMenu.Items.Add($separator)

# 終了メニューアイテム
$exitMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$exitMenuItem.Text = "終了"
$contextMenu.Items.Add($exitMenuItem)

# NotifyIconにコンテキストメニューを関連付け
$notifyIcon.ContextMenuStrip = $contextMenu

# スクリプト実行フラグとカウンター
$script:isRunning = $true
$script:counter = 0

# 終了メニューアイテムのクリックイベントハンドラー
$exitMenuItem.Add_Click({
    $script:isRunning = $false
    $notifyIcon.Visible = $false
    $form.Close()
    [System.Windows.Forms.Application]::Exit()
})

# タスクトレイアイコンのダブルクリックイベントハンドラー
$notifyIcon.Add_DoubleClick({
    [System.Windows.Forms.MessageBox]::Show("スクリプトの実行回数: $script:counter 回", "ステータス情報", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})

# 定期的に実行する処理を開始するタイマーの作成
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 5000  # 5秒ごとに実行
$timer.Add_Tick({
    # ここに定期的に実行したい処理を記述
    $script:counter++
    
    # 例: ログファイルに書き込み
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] 処理実行 ($script:counter 回目)"
    $logMessage | Out-File -Append -FilePath "$env:TEMP\taskbar_script_log.txt"
    
    # ステータスメニューの更新
    $statusMenuItem.Text = "ステータス: 実行中 (実行回数: $script:counter)"
    
    # バルーンチップ表示（10回ごと）
    if ($script:counter % 10 -eq 0) {
        $notifyIcon.ShowBalloonTip(
            3000,  # 表示時間（ミリ秒）
            "処理実行通知",
            "バックグラウンド処理が $script:counter 回実行されました。",
            [System.Windows.Forms.ToolTipIcon]::Info
        )
    }
})

# タイマー開始
$timer.Start()

# タスクトレイへの通知
$notifyIcon.ShowBalloonTip(
    5000,
    "スクリプト開始",
    "タスクトレイ常駐スクリプトが開始されました。右クリックで操作メニューを表示します。",
    [System.Windows.Forms.ToolTipIcon]::Info
)

# メッセージループの開始
[System.Windows.Forms.Application]::Run($form)

# スクリプト終了時の後処理
$timer.Stop()
$notifyIcon.Dispose()
