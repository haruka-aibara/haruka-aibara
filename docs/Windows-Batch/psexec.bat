@echo off
cd /d %~dp0

set /p TARGET_PC="Enter target computer name or IP: "
set /p USERNAME="Enter username: "
set /p PASSWORD="Enter password: "
set /p COMMAND="Enter command to execute: "

echo Executing command on remote system...
PsExec.exe \\%TARGET_PC% -u %USERNAME% -p %PASSWORD% cmd /c "%COMMAND%"

if %ERRORLEVEL% EQU 0 (
    echo Command executed successfully.
) else (
    echo Error executing command. Error code: %ERRORLEVEL%
)

pause
exit
