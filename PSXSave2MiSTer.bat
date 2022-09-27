::Script written by Sam Potter

::Script checks the user's network for a connected MiSTer and transfers an individual PSX save,
::then converts said save to the PSX saves directory on the MiSTer.
::Files can either be dragged and dropped onto this script, or paths can be typed in manually
::(This was mosly a personal problem I ran into on paternal leave and got tired of doing the work myself...)

@echo off
set FileExt=
set GameName=
set SavePath=
set Hostname=mister

echo "|=====================================================================|"
echo "|   _____   _______   __  _          __  __ _  _____ _______          |"
echo "| |  __ \ / ____\ \ / / | |        |  \/  (_)/ ____|__   __|          |"
echo "| | |__) | (___  \ V /  | |_ ___   | \  / |_| (___    | | ___ _ __    |"
echo "| |  ___/ \___ \  > <   | __/ _ \  | |\/| | |\___ \   | |/ _ | '__|   |"
echo "| | |     ____) |/ . \  | || (_) | | |  | | |____) |  | |  __| |      |"
echo "| |_|____|_____//_/ \_\  \__\___/  |_|  |_|_|_____/   |_|\___|_|      |"
echo "|  / ____|                        | |                                 |"
echo "| | |     ___  _ ____   _____ _ __| |_ ___ _ __                       |"
echo "| | |    / _ \| '_ \ \ / / _ | '__| __/ _ | '__|                      |"
echo "| | |___| (_) | | | \ V |  __| |  | ||  __| |                         |"
echo "|  \_____\___/|_| |_|\_/ \___|_|   \__\___|_|                         |"
echo "|=====================================================================|"                                                                 

echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo Welcome!
echo For your convienience, make sure your MiSter is powered on and connected to your network.
echo If the MiSTer is using a different Hostname than default, please open this script with a text editor
echo and change the 'Hostname' varable on line 12.
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
pause
cls

:Start
::Pinging the default host name of the MiSTer on the user's network. If we find it, move on, if not, go to fail.

:CheckForMiSTer
echo Checking network for your MiSTer...

for /f "tokens=5,4,7" %%a in ('ping -n 1 %Hostname%') do (
    if "x%%a"=="xnot" goto :connectionfail
    if "x%%c"=="x1," echo Connected! & goto SaveArgCheck
)

::Check args to see if user dragged and dropped a file, if not, go to prompt
:SaveArgCheck
if "%1"=="" (
    goto GetSave
    ) else (
        goto SaveCheck
)

::If the script made it here, it means the user did not drag and drop a file onto the script.
::Or the user did not use a file with the extension ".srm"
:GetSave
echo Okay, lets grab your PSX save file.
echo Enter the full path of the PSX save file.
set /p "SavePath=Make sure to include the file extension! Ex.(C:\Users\USERNAME\Downloads\...\GAMESAVE.srm): "
for %%i in ("%SavePath%") do (
    set FileExt=%%~xi
    set GameName=%%~ni
)

::This parses through the file given if dragged and dropped to confirm it has the right extension
:SaveCheck
if "%1"=="" goto SkipSaveParse
for %%i in ("%1") do (
        set FileExt=%%~xi
        )
        if not "%FileExt%"==".srm" (
            goto FileWarning 
        ) else (
            goto Convert
)
::Same as above but for the user given path
:SkipSaveParse
if not "%FileExt%"==".srm" (
    goto FileWarning 
    ) else ( 
    goto GetSaveConvert
)

::Script reaches this point when a file with the wrong extension is entered. (So far) this script can only convert srm files...
:FileWarning
echo [91mYour save does not have a .srm extension. This script cannot convert your save.[0m 
echo Please make sure the file has a .srm extension.
if "%1"=="" (
    call :GetSave
) else (
    exit
)


::Converting individual PSX saves is as simple as renaming a file extension so we do that here.
::One thing to note is that this script takes the file name, so if the file name is different on the MiSTer...
::It will not automatically be mounted into the memory card slot. Otherwise it must be mounted manually.

:Convert
echo copying %~n1 save to the MiSTer
copy /s /Y %1 "\\mister\sdcard\saves\PSX\%~n1.sav"
goto end

:GetSaveConvert
echo copying %GameName% save to MiSTer
xcopy /s /Y "%SavePath%" "\\mister\sdcard\saves\PSX\%GameName%.sav"
goto end

::Script reaches here if the MiSTer is not found on the network. Prompts user to check connections.
:connectionfail
echo [91mCannot connect to MiSTer...[0m
echo Please make sure your mister is turned on, and connected to your network.
echo If you just turned your MiSTer on, please wait a minute, then run this script again.
echo Press any button to close this program...
timeout /t -1 >nul
exit

::Success!
:end
echo [92mSave successfully transfered and converted! This window will close after 10 seconds.[0m
timeout /t 10 >nul
exit