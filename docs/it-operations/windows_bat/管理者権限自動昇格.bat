@echo off
cd /d %~dp0

rem PATH補完
setlocal
set PATH=%PATH%;%windir%\system32;%windir%\System32\WindowsPowerShell\v1.0;%windir%\System32\wbem

rem 自動管理者実行
whoami /priv | find "SeDebugPrivilege" > nul
if %ERRORLEVEL% neq 0 (
@C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe start-process '%~0' -verb runas
exit
)

rem PowerShell実行ポリシーを変更
@powershell -command "Set-ExecutionPolicy RemoteSigned"

echo 処理が完了しました。
pause & exit
