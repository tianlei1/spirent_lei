@echo off


::set current console corlor as green
color 2
::set root directory
SET STC_BUILD_ROOT=c:\work\testcenter
::rename console as cmd parameter 2 
title %2%

::echo %1% %2%

::remind usage if no parameter
if "%1%" equ "" (
    goto :HELP
)

::parse argv from console
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

::exit
goto :eof




::function <HELP> 
:HELP
	echo              dos command usage: 
	echo 1. dos configure [x86, x64, Any Cpu]: configure build 32bit\64bit\any
	echo 2. dos cd [l2l3,ccl,...]: cd integration top 3 sub directory xxx
	echo 3. dos cdi: cd root directory integration
	echo 4. dos bd [ui, bll, l2l3, ccl]: build 64bit ui,bll,l2l3,ccl 
	echo 5. dos bd32 [ui, bll, l2l3, ccl]: build 32bit ui,bll,l2l3,ccl 
	echo 6. dos start [stc, stc_32, stc_debug]: launch ..\integration\bin\Debug\TestCenter.exe
	echo 7. dos kill stc: kill ..\integration\bin\Debug\TestCenter.exe
	echo 8. dos connect [ltian, vm, aft-a1-dev03/10.14.19.16]: connect to build server, calabasas vm, chassis
    echo 9. dos update_iq: generate iq view json files and install to bin\debug_x64
    echo 10.dos run_ut [l2l3,ccl,...]: start bll ut test
goto :eof    


::function <CONFIGURE>  :setup build env for 32bit/64bit/anycpu
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


::function <UPDATE_IQ>  :generate iq yaml files and move to bin\debug_x64
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
		start mstsc -v bdc-ltian.calenglab.spirentcom.com
	)else if "%2%" equ "ltian" (
        sshpass -p ltian ssh -o StrictHostKeyChecking=no ltian@10.61.43.53
	)else (
		if exist "C:\Users\ltian\.ssh\known_hosts" (
			del C:\Users\ltian\.ssh\known_hosts
		)
		echo %2% | findstr "^[a-zA-Z]" > nul && (
            echo sshpass connect to %2%.calenglab.spirentcom.com
			sshpass -p dia@MADF ssh -o StrictHostKeyChecking=no root@%2%.calenglab.spirentcom.com
		) || (
            echo sshpass connect to %2%
			sshpass -p dia@MADF ssh -o StrictHostKeyChecking=no root@%2%
		)
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


