@echo off


::set current dos cmd console's color as green
color 2
::rename current dos cmd console's name as parameter 2 
title %2%
::set root directory
SET STC_BUILD_ROOT=c:\work\testcenter

::echo %1% %2%

::remind usage if no command-line arguments
if "%1%" equ "" (
    goto :HELP
)

::parse first argv
if %~1 equ help             goto :HELP
if %~1 equ cdi              goto :CDI
if %~1 equ cd               goto :CD
if %~1 equ configure        goto :CONFIGURE
if %~1 equ bd               goto :BD
if %~1 equ bd32             goto :BD32
if %~1 equ update_iq        goto :UPDATE_IQ
if %~1 equ table_build      goto :TABLE_BUILD
if %~1 equ run_ut           goto :RUN_UT
if %~1 equ launch           goto :LAUNCH
if %~1 equ kill             goto :KILL
if %~1 equ connect          goto :CONNECT
if %~1 equ upload           goto :UPLOAD
if %~1 equ download         goto :DOWNLOAD
if %~1 equ poweroff         goto :POWEROFF
if %~1 equ restart          goto :RESTART
if %~1 equ install          goto :INSTALL
if %~1 equ uninstall        goto :UNINSTALL
if %~1 equ upgrade          goto :UPGRADE

::exit
goto :end








::function <HELP> 
:HELP
    echo              dos command usage: 
    echo 1. dos configure [x86, x64, Any Cpu]: configure build 32bit\64bit\any
    echo 2. dos cd [l2l3,ccl,...]: cd integration top 3 sub directory xxx
    echo 3. dos cdi: cd root directory integration
    echo 4. dos bd [ui, bll, l2l3, ccl]: build 64bit ui,bll,l2l3,ccl 
    echo 5. dos bd32 [ui, bll, l2l3, ccl]: build 32bit ui,bll,l2l3,ccl 
    echo 6. dos launch [stc, stc_32, stc_debug]: launch ..\integration\bin\Debug\TestCenter.exe
    echo 7. dos kill stc: kill ..\integration\bin\Debug\TestCenter.exe
    echo 8. dos connect [ltian, vm, aft-a1-dev03/10.14.19.16]: connect to build server, calabasas vm, chassis
    echo 9. dos update_iq: generate iq view json files and install them to bin\debug_x64
    echo 10.dos run_ut [l2l3,ccl,...]: start bll ut test
    echo 11.dos upload [src_file]: upload windows src_file to linux build server ltian@10.61.43.53:~/share 
    echo 12.dos download [target_file] [target_dir]: download target_file from linux build server ltian@10.61.43.53:~/share/target_file to windows target_dir
    echo 13.dos poweroff: poweroff laptop
    echo 14.dos restart: restart laptop
    echo 15.dos install [stc]: install C:\Users\ltian\Desktop\stc\9.90\"Spirent TestCenter Application x64"
    echo 16.dos uninstall [stc]: uninstall "Spirent TestCenter Application x64"
    echo 17.dos upgrade [9.90.xxxx]: upgrade integration to 9.90.xxxx
goto :eof  


::function <CONFIGURE>  :setup build env for 32bit/64bit/anycpu on windows
:CONFIGURE
    SET STC_BUILD_ROOT=c:\work\testcenter
    cd %STC_BUILD_ROOT%
    python genSln.py
    ::pushd C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\Common7\Tools
    call VsDevCmd.bat -arch=%2%
    popd
goto :eof


::function CDI
:CDI
    cd %STC_BUILD_ROOT%
goto :eof


::function <CD>
:CD
    if %~2 equ work (
        cd C:\work
        goto :eof
    )
    
    for /d %%d in ("%STC_BUILD_ROOT%\*") do (
        if "%%~nxd" equ "%2%" (
            cd %%d
            goto :eof
        )
    ) 
    
    for /d %%d in ("%STC_BUILD_ROOT%\*") do (
        for /d %%d in ("%%d\*") do (
            if "%%~nxd" equ "%2%" (
                cd %%d
                goto :eof
            )
            call :FindTargetDirectory %%d %2%
        )
    )
goto :eof


::function <BD>  :which is used to build 64bit bll or ui 
:BD
    if "%2%" equ "bll" (
        cd %STC_BUILD_ROOT%
        .\scons.cmd -j 16 -f SConstruct.bll debug=1 target=bll-win64 
    )else if "%2%" equ "ui" (
        cd %STC_BUILD_ROOT%
        msbuild.exe TestCenter.UI.Gen.sln /t:build /p:Configuration=Debug /p:Platform="x64" /m:4
    )else (
        cd %STC_BUILD_ROOT%\content\traffic\%2%\bll\
        %STC_BUILD_ROOT%\scons.cmd -j 16 debug=1 -f SConscript.bll target=bll-win64
    )
    cd %STC_BUILD_ROOT% 
goto :eof


::function <BD32>  :which is used to build 32bit bll or ui 
:BD32
    if "%2%" equ "bll" (
        cd %STC_BUILD_ROOT%
        .\scons.cmd -j 12 -f SConstruct.bll debug=1 target=bll-win32
    )else if "%2%" equ "ui" (
        cd %STC_BUILD_ROOT%
        msbuild.exe TestCenter.UI.Gen.sln /t:build /p:Configuration=Debug /p:Platform="Win32" /m:4
    )else (
        cd %STC_BUILD_ROOT%\content\traffic\%2%\bll\
        %STC_BUILD_ROOT%\scons.cmd -j 16 debug=1 -f SConscript.bll target=bll-win32
    )
    cd %STC_BUILD_ROOT% 
goto :eof


::function <UPDATE_IQ>  :generate iq json files and move to bin\debug_x64
:UPDATE_IQ
cd %STC_BUILD_ROOT%\framework\tools\MagellanFileGenerator\ViewGenerator\
    python batch-generate.py
    copy *.json %STC_BUILD_ROOT%\framework\def\Templates\EnhancedResults\Views\
    copy *.json %STC_BUILD_ROOT%\bin\Debug_x64\Templates\EnhancedResults\Views\
    del *.json
    cd %STC_BUILD_ROOT%
goto :eof


::function <TABLE_BUILD>
:TABLE_BUILD
    java -jar Table.jar submit -dir . -sln TestCenter -debug no -server-selection Windows Linux -archive yes  -runUnitTests yes -changelist %2% -regression no -coverage no
goto :eof


::function <RUN_UT>  :run all bll ut case
:RUN_UT
    cd %STC_BUILD_ROOT%\bin\Debug_x64\
    if "%2%" equ "" (
        echo "run all plugins UnitTest"
        python %STC_BUILD_ROOT%\framework\tools\testRunner\testRunner.py --runInParallel=8 --bll --stak --archive 
    )else (
        echo "run plugin %2% UnitTest"
        set plugin="test%2%.exe%
        set pluginResult="%plugin%Result.html"
    )
goto :eof



::function <LAUNCH>  :launch stc [stc_32: 32bit, stc: 64bit, stc_debug: enable debug] 
:LAUNCH
    if "%2%" equ "stc_32" (
        start %STC_BUILD_ROOT%\bin\Debug\TestCenter.exe
    )else if "%2%" equ "stc" (
        echo "launch 64bit TestCenter.exe"
        start %STC_BUILD_ROOT%\bin\Debug_x64\TestCenter.exe
    )else if "%2%" equ "stc_debug" (
        echo "launch bin\Debug_x64\TestCenter.exe --enableExceptionDebug=true"
        start %STC_BUILD_ROOT%\bin\Debug_x64\TestCenter.exe --enableExceptionDebug=true
    )
goto :eof


::function <KILL>  :kill stc 
:KILL
    if "%2%" equ "stc" (
        taskkill /f /im TestCenter.exe
        taskkill /f /im TestCenterSession.exe
    )
goto :eof


::function <CONNECT>  :ssh connect to build server/chassis/vm 
:CONNECT 
    if "%2%" equ "vm" (
        REM start mstsc -v bdc-ltian.calenglab.spirentcom.com
        
        REM windows which enabled rdp
        SET SERVER=host_name
        SET USERNAME=usr_name
        SET PASSWORD=password

        REM Store the credentials
        cmdkey /generic:TERMSRV/%SERVER% /user:%USERNAME% /pass:%PASSWORD%

        REM Connect to the remote desktop
        start mstsc /v:%SERVER%

        REM Optionally delete the stored credentials
        REM cmdkey /delete:TERMSRV/%SERVER%

    )else if "%2%" equ "ltian" (
        sshpass -p <password> ssh -o StrictHostKeyChecking=no ltian@10.61.43.53
    )else (
        if exist "C:\Users\ltian\.ssh\known_hosts" (
            del C:\Users\ltian\.ssh\known_hosts
        )
        echo %2% | findstr "^[a-zA-Z]" > nul && (
            echo sshpass connect to %2%.calenglab.spirentcom.com
            sshpass -p <password> ssh -o StrictHostKeyChecking=no root@%2%.calenglab.spirentcom.com
        ) || (
            echo sshpass connect to %2%
            sshpass -p <password> ssh -o StrictHostKeyChecking=no root@%2%
        )
    )
goto :eof

::function <UPLOAD>
:UPLOAD
    sshpass -p <password> scp %~2 ltian@10.61.43.53:~/share
goto :eof


::function <DOWNLOAD>
:DOWNLOAD
    sshpass -p <password> scp ltian@10.61.43.53:~/share/%~2  %~3
goto :eof


::funtion <POWEROFF>
:POWEROFF  
    REM Force shutdown the PC immediately
    shutdown /s /f /t 0
goto :eof


::function <RESTART>
:RESTART 
    REM Force restart the pc immediately
    shutdown /r /f /t 0
goto :eof


::funtion <INSTALL>
:INSTALL
    REM install C:\Users\ltian\Desktop\stc\9.90
    if %~2 equ stc (
        echo       .........STC install in progress.........
        REM start /wait "" "C:\Users\ltian\Desktop\stc\9.90\Spirent TestCenter Application x64.exe" /silent /install
        "C:\Users\ltian\Desktop\stc\9.90\Spirent TestCenter Application x64.exe" /silent /install /norestart
        if %errorlevel% equ 0 (
            echo       .........install Successful.........
        )
    )
goto :eof


::funtion <UNINSTALL>
:UNINSTALL
    if %~2 equ stc (
        REM uninstall Spirent TestCenter Application x64.exe
        echo       .........STC uninstall in progress.........
        start /wait "" "C:\Users\ltian\Desktop\stc\9.90\Spirent TestCenter Application x64.exe" /silent /uninstall 
        echo %errorlevel%
        if %errorlevel% equ 0 (
            echo       .........uninstall Completed.........
        )else (
             echo       .........uninstall Failed.........
        )
    )else (
        echo       .........Invalid parameter......... 
    )
goto :eof

::function <UPGRADE>
:UPGRADE
    REM uninstall installed stc 
    set para=stc
    call :UNINSTALL %%d %para%
    
    REM copy ci build to local 
    echo       .........Copy CI build %2% in progress......... 
    copy "\\calengnas01.spirentcom.com\software-builds\spirent\testcenter\integration\9.90\gui_bll\%~2\Spirent TestCenter Application x64.exe" "C:\Users\ltian\Desktop\stc\9.90\"
    if %errorlevel% equ 0 (
        echo       .........Copy CI build %2% Completed.........
        set para=stc
        call :INSTALL %%d %para%
    )else (
        echo       .........Copy CI build %2% failed.........
     )
goto :eof


::function FindTargetDirectory
:FindTargetDirectory
for /d %%d in ("%~1\*") do (    
    if "%%~nxd" equ "%2%" (
        echo FindTargetDirectory Found directory: %%d
        cd %%d
        goto :eof
    )
)
goto :eof


