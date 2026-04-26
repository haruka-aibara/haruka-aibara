$FileName = "log.txt"
$ProcessName = "notepad"

"Time,Working set(MB)" | Out-File -Append $FileName
while($TRUE){
    $d = Get-Date -Format "yyyy-MM-dd HH:mm:ss.ff"
    $p = Get-Process -Name $ProcessName | Select-Object WS
    $p | ForEach-Object {$mem = 0} {$mem += $_.WS}
    $mem = ($mem/1024/1024).ToString()
    $d+', '+$mem+'MB' | Out-File -Append $FileName
    Start-Sleep -Seconds 1
}
