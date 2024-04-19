@echo off 
title Frozen Multi Tool 
color 0c

goto main
:main 
echo.

echo FROZEN MULTI TOOL


echo (1) = Ip / Website Pinger 
echo (2) = Remote Desktop Connection 
echo (3) = IP Lookup 

set choiceinput=
set /p choiceinput= Choose : 

if %choiceinput%==1 goto pinger 
if %choiceinput%==2 goto RDC
if %choiceinput%==3 goto iplook

:pinger
cls
Color 0c
set adress=
set /p adress= Paste the ip or website link :

set numberping=
set /p numberping= number of ping do you want : 

ping  -4  -n %numberping% %adress%
pause
cls 

goto main

:RDC

cd files >nul
mode 100, 30
color 0B
title PsExec
set success=[92m[+][0m
set warning=[91m[!][0m
set info=[94m[*][0m
set servicename=winrm%random%
cls
chcp 65001 >nul
echo    Computer  
set /p domain=">> "
echo.
echo     Username
set /p user=">> "
echo.
echo    Password  
set /p pass=">> "
echo.
echo %info% Connecting to %domain%...
rem Disconnects any running connections
net use \\%domain% /user:%user% %pass% >nul 2>&1
rem Connects to the PC with SMB
net use \\%domain% /user:%user% %pass% >nul 2>&1

if /I "%errorlevel%" NEQ "0" (
  echo %warning% Invalid Credentials or Network Issue
  pause
  goto start
)

echo %success% Connected!

goto main 

:winrm
echo %info% Checking for WinRM...
chcp 437 >nul
powershell -Command "Test-WSMan -ComputerName %domain%" >nul 2>&1
set errorcode=%errorlevel%
chcp 65001 >nul

if /I "%errorcode%" NEQ "0" (
  echo %info% Creating Remote Service...
  rem Creates a service on the remote PC that enables WinRM
  sc \\%domain% create %servicename% binPath= "cmd.exe /c winrm quickconfig -force"
  echo %success% Configuring WinRM...
  sc \\%domain% start %servicename%
  echo %info% Deleting Service...
  sc \\%domain% delete %servicename%
  goto menu
)

if /I "%errorcode%" EQU "0" (
  chcp 65001 >nul
  echo %success% %domain% has WinRM Enabled!
  timeout /t 3 >nul
  goto menu
)

:menu
cls
call :banner
echo.
echo %info% Connected to %domain%
echo.
echo [95m[1][0m » Shell
echo [95m[2][0m » Files ( Require admin acces )
echo [95m[4][0m » Shutdown
echo [95m[5][0m » Disconnect
echo.
set /p " =>> " <nul
choice /c 12345 >nul

if /I "%errorlevel%" EQU "1" (
  cls
  echo.
  echo %success% Opening Remote Shell...
  echo.
  rem Opens remote cmd with WinRS
  winrs -r:%domain% -u:%user% -p:%pass% cmd
  goto menu
)

if /I "%errorlevel%" EQU "2" (
  start "" "\\%domain%\C$"
  cls
  goto menu
)

if /I "%errorlevel%" EQU "3" (
  cls
  echo.
  echo %info% Gathering Info..
  copy "info.bat" "\\%domain%\C$\ProgramData\info.bat" >nul
  winrs -r:%domain% -u:%user% -p:%pass% C:\ProgramData\info.bat
  pause
  del "\\%domain%\C$\ProgramData\info.bat"
  goto menu
)

if /I "%errorlevel%" EQU "4" (
  winrs -r:%domain% -u:%user% -p:%pass% "shutdown /s /f /t 0"
  cls
  goto menu
)

if /I "%errorlevel%" EQU "5" (
  net use \\%domain% /d /y >nul 2>&1
  goto start
  
  :iplook
  
  title IP Lookup by FROZEN

color 0d

:ip
cls
echo.
set/p IP="Enter IP Adress >: "
curl -s http://ip-api.com/line/%IP%?fields=message,country,regionName,zip,isp
pause
goto start

