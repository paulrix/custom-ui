@echo off
echo.
echo =========================================================
echo CCH Tagetik UI Customisation Script by Paul Rix
echo =========================================================

REM  IMPORTANT NOTES:
REM  ------------------------------------
REM  JBoss/Wildfly Windows service must be started
REM  Run this script from any folder e.g d:\customUI etc.
REM  The following files must be in the same folder as this script:
REM    -Image files 'top.png', 'background.png', and 'login.png'
REM    -Module_configured.xml 
REM    -ConfigStandaloneXML.cli
REM    -ConfigServiceBAT.ps1


REM Setting current directory variable
set "curr_dir=%cd%"
echo Current directory is %curr_dir%

:set_JBOSS_HOME
echo.
set /p JBOSS_HOME=Enter JBOSS_HOME (e.g. c:\jboss d:\wildfly etc.):
echo Verifying %JBOSS_HOME%...
IF NOT EXIST %JBOSS_HOME% (
echo  ...path invalid
goto :set_JBOSS_HOME
)
echo path %JBOSS_HOME% exists


:set_tagetik_dir
echo.
set /p tagetikdir=Enter Tagetik install folder (e.g. d:\tagetik):
echo Verifying %tagetikdir%...
IF NOT EXIST %tagetikdir% (
echo ...path invalid
goto :set_tagetik_dir
)
echo path %tagetikdir% exists


REM Checking if JAVA_HOME is set already
echo.
IF [%JAVA_HOME%] == [] goto :set_JAVA_HOME 
echo JAVA_HOME set to %JAVA_HOME%
goto :start_customisation

:set_JAVA_HOME
echo.
set /p JAVA_HOME=Enter JAVA_HOME e.g. D:\jdk1.7.0_45:
echo Verifying %JAVA_HOME%...
IF NOT EXIST %JAVA_HOME% (
echo ...path invalid
goto :set_JAVA_HOME
)
echo path %JAVA_HOME% exists



:start_customisation

echo.
echo [1/10] Create custom folders and move image files into them
echo -------------------------------------------------------------------
pause
echo.
mkdir %JBOSS_HOME%\standalone\customimages
mkdir %JBOSS_HOME%\modules\tgk\img\main

copy /-y %curr_dir%\login.png %JBOSS_HOME%\standalone\customimages
copy /-y %curr_dir%\background.png %JBOSS_HOME%\standalone\customimages
copy /-y %curr_dir%\top.png %JBOSS_HOME%\standalone\customimages

copy /-y %curr_dir%\module_configured.xml %JBOSS_HOME%\modules\tgk\img\main\module.xml
echo ...done
pause

echo. 
echo [2/10] Create customimage.jar with image files
echo -------------------------------------------------------------------
pause
echo.
cd %JBOSS_HOME%\standalone
%JAVA_HOME%\bin\jar.exe -cf %JBOSS_HOME%\modules\tgk\img\main\customimages.jar customimages
echo ...done
pause

echo.
echo [3/10] Back up standalone.xml file to standalone.xml.backup
echo -------------------------------------------------------------------
pause
echo.
copy /-y %JBOSS_HOME%\standalone\configuration\standalone.xml %JBOSS_HOME%\standalone\configuration\standalone.xml.backup
echo ...done
pause

echo.
echo [4/10] Edit standalone.xml file with custom image folders 
echo -------------------------------------------------------------------
pause
echo.
copy /-y %curr_dir%\ConfigStandaloneXML.cli %JBOSS_HOME%\bin
cd %JBOSS_HOME%\bin
set "NOPAUSE=true"
call jboss-cli.bat --file=ConfigStandaloneXML.cli
echo ...done
pause

echo.
echo [5/10] Back up service.bat file to service.bat.backup
echo -------------------------------------------------------------------
pause
echo.
cd %tagetikdir%\bin\
copy service.bat /-y service.bat.backup
echo ...done
pause

echo.
echo [6/10] Edit JAVA_OPTS in service.bat with references to .png files
echo -------------------------------------------------------------------
pause
echo.
set servicefilepath=%tagetikdir%\bin\service.bat
PowerShell.exe -ExecutionPolicy Bypass -File "%curr_dir%\ConfigServiceBAT.ps1" %servicefilepath%
echo ...done
pause

echo.
echo [7/10] Stop JBoss7 service
echo -------------------------------------------------------------------
pause
echo.
net stop JBOSS7
echo Pinging to pass time while JBOSS is stopping...
PING 127.0.0.1 -n 6
echo ...done
pause

echo.
echo [8/10] Uninstall JBOSS7 Windows service
echo -------------------------------------------------------------------
pause
echo.
cd %tagetikdir%\bin\
call service_out.bat
echo ...done
pause

echo.
echo [9/10] Reinstall JBOSS7 service
echo -------------------------------------------------------------------
pause
echo.
cd %tagetikdir%\bin\
call service_in.bat

echo.
echo [10/10] Restart JBOSS7 service to complete customisation
echo -------------------------------------------------------------------
pause
echo.
net start JBOSS7
echo ...done
echo.
echo Script completed. Wait for JBoss7 to fully start before logging in.
pause







