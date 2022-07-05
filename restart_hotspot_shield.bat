@echo off

@rem Check for permissions

IF "%PROCESSOR_ARCHITECTURE%" equ "amd64" ( >nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system") else (>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system")

@rem If error flag set, we do not have admin.
if '%errorlevel%' neq '0' (
    echo [.admin] Administrative Privileges not found. Requesting.
    goto UACPrompt 
    ) else (  
    goto gotAdmin 
     )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

@rem Setting Variables as of Hotspot Sheild Version 11.1.4
        
set prc = "hshld_11.1.4"
set hsexe = "hsscp.exe"

goto checkrunning

:checkrunning
    echo [.exe] Checking If Hotspot Sheild is Running...
    wmic process where (name=%hsexe %) get commandline | findstr /i %hsexe %> NUL
    if errorlevel 1 (
        @rem It is not running. We can safely restart the process.
        goto exitprc
    ) else (
        @rem It is running. We need to exit Hotspot Shield & restart the process.
        goto extishield
    )

    pause

:extishield
    echo [.exe] Hotspot Shield is Running. Quitting
    taskkill /f /t /im %hsexe % 
    echo [.exe] Exited Hotspot Sheild Successfully.
    goto exitprc 

:starths
    echo [.exe] Starting Hotspot Shield. Please Wait!
    cd %programfiles(x86)%/Hotspot^ Shield/11.1.4/bin/
    start hsscp.exe
    goto exitp

:exitprc
    echo [.prc] Restarting Hotspot Sheild Process %prc %...
    net stop %prc %
    net start %prc %
    echo [.prc] Restart Successfull.
    goto exitp

@REM :final
@REM     echo [.exe] Do you want to start Hotspot Shield Now? (y/n)
@REM     set /p ans = ""
@REM     if %ans %=="y" ( goto starths ) else (  )
    
:exitp
    exit /b 0