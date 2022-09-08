@echo off
set Hostname=mister
set MiSTerPSXSaves=\\mister\sdcard\saves\PSX
set GameName=""
set FullPath=""
set FullName=""
set /a count=0

:CheckForMiSTer
echo Checking network for your MiSTer...

for /f "tokens=5,4,7" %%a in ('ping -n 1 %Hostname%') do (
    if "x%%a"=="xnot" goto connectionfail
    if "x%%c"=="x1," echo Connected! & goto GrabSave
)


:GrabSave
set /p "GameName= What game did you want to grab the save of? "
for %%i in (%MiSTerPSXSaves%\*.*) do ( echo %%~i >> list.txt )
setlocal enabledelayedexpansion
for /F "delims=\ tokens=5" %%a in ('findstr /I /c:"%GameName%" list.txt') do (
    echo %%~na
    set FullName=%%~na
    set /a count+=1
    if !count! geq 2 goto TooManyFiles
)

:SetPath
del list.txt
set FullPath=%MiSTerPSXSaves%\%FullName%
if exist %FullPath% (
    echo Found File!
    timeout /t 1 >nul
    echo "%FullPath%"
    copy /y "%FullPath%.sav" "%USERPROFILE%\Downloads\%FullName%.srm"
    pause
    if %errorlevel%==0 goto end
    if not %errorlevel%==0 goto FailtoCopy
) else (
    echo Could not find %FullName%.sav. Please make sure you are correctly spelling the file name.
    echo Or search for a subtitle if it has a simliarly named title "Ex. (Final Fantasy VII, Final Fantasy Tactics, etc..."
    call :GrabSave
)

:FailtoCopy
echo [91mFailed to copy save.[0m
pause
exit

:connectionfail
echo [91mCannot connect to MiSTer...[0m
echo Please make sure your MiSTer is turned on, and connected to your network.
echo If you just turned your MiSTer on, please wait a minute, then run this script again.
echo Press any button to close this program...
timeout /t -1 >nul
exit

:end
cls
echo [92mSave successfully transfered and converted! This window will close after 10 seconds.[0m
timeout /t 10 >nul
exit

:TooManyFiles
del list.txt
set count=0
echo Multiple Files were found, please be more specific
call :GrabSave