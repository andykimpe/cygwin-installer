@echo off

rem Set CYGWIN_BASE variable to the installation directory.
rem By default this will be C:\Users\<username>\cygwin
set CYGWIN_BASE=%USERPROFILE%\cygwin

rem Set CPU to the desired version of Cygwin.
rem Use x86 for 32-bit Cygwin, or x86_64 for 64-bit Cygwin
set CPU=x86_64

rem Do no change anything past this point!

if not exist %CYGWIN_BASE% goto install
echo The directory %CYGWIN_BASE% already exists.
echo Cannot install over an existing installation.
goto exit

:install
echo About to install Cygwin %CPU% on %CYGWIN_BASE%
pause

mkdir "%CYGWIN_BASE%"
cd %CYGWIN_BASE%

rem Windows has no built-in wget or curl, so we generate a VBS script to do the same
set DLOAD_SCRIPT=%TEMP%\download-%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs
echo Option Explicit                                                    >  %DLOAD_SCRIPT%
echo Dim args, http, fileSystem, adoStream, url, target, status         >> %DLOAD_SCRIPT%
echo.                                                                   >> %DLOAD_SCRIPT%
echo Set args = Wscript.Arguments                                       >> %DLOAD_SCRIPT%
echo Set http = CreateObject("WinHttp.WinHttpRequest.5.1")              >> %DLOAD_SCRIPT%
echo url = args(0)                                                      >> %DLOAD_SCRIPT%
echo target = args(1)                                                   >> %DLOAD_SCRIPT%
echo WScript.Echo "Getting '" ^& target ^& "' from '" ^& url ^& "'..."  >> %DLOAD_SCRIPT%
echo.                                                                   >> %DLOAD_SCRIPT%
echo http.Open "GET", url, False                                        >> %DLOAD_SCRIPT%
echo http.Send                                                          >> %DLOAD_SCRIPT%
echo status = http.Status                                               >> %DLOAD_SCRIPT%
echo.                                                                   >> %DLOAD_SCRIPT%
echo If status ^<^> 200 Then                                            >> %DLOAD_SCRIPT%
echo    WScript.Echo "FAILED to download: HTTP Status " ^& status       >> %DLOAD_SCRIPT%
echo    WScript.Quit 1                                                  >> %DLOAD_SCRIPT%
echo End If                                                             >> %DLOAD_SCRIPT%
echo.                                                                   >> %DLOAD_SCRIPT%
echo Set adoStream = CreateObject("ADODB.Stream")                       >> %DLOAD_SCRIPT%
echo adoStream.Open                                                     >> %DLOAD_SCRIPT%
echo adoStream.Type = 1                                                 >> %DLOAD_SCRIPT%
echo adoStream.Write http.ResponseBody                                  >> %DLOAD_SCRIPT%
echo adoStream.Position = 0                                             >> %DLOAD_SCRIPT%
echo.                                                                   >> %DLOAD_SCRIPT%
echo Set fileSystem = CreateObject("Scripting.FileSystemObject")        >> %DLOAD_SCRIPT%
echo If fileSystem.FileExists(target) Then fileSystem.DeleteFile target >> %DLOAD_SCRIPT%
echo adoStream.SaveToFile target                                        >> %DLOAD_SCRIPT%
echo adoStream.Close                                                    >> %DLOAD_SCRIPT%
echo.                                                                   >> %DLOAD_SCRIPT%

if %CPU%==x86 (
  rem 32 bit
  rem Install base cygwin
  cscript /nologo %DLOAD_SCRIPT% https://cygwin.com/setup-x86.exe setup-x86.exe
  setup-x86.exe --no-admin --root %CYGWIN_BASE% --quiet-mode --no-shortcuts --no-startmenu --allow-unsupported-windows --arch x86 --force-current --no-desktop --no-replaceonreboot --no-verify --no-version-check --no-warn-deprecated-windows --no-write-registry --only-site --site https://mirrors.kernel.org/sourceware/cygwin-archive/20221123/ -l %CYGWIN_BASE%\var\cache\apt\packages --packages dos2unix,wget
) else (
if %PROCESSOR_ARCHITECTURE%==x86 (
  rem 32 bit
  rem Install base cygwin
  cscript /nologo %DLOAD_SCRIPT% https://cygwin.com/setup-x86.exe setup-x86.exe
  setup-x86.exe --no-admin --root %CYGWIN_BASE% --quiet-mode --no-shortcuts --no-startmenu --allow-unsupported-windows --arch x86 --force-current --no-desktop --no-replaceonreboot --no-verify --no-version-check --no-warn-deprecated-windows --no-write-registry --only-site --site https://mirrors.kernel.org/sourceware/cygwin-archive/20221123/ -l %CYGWIN_BASE%\var\cache\apt\packages --packages dos2unix,wget
) else (
  rem 64 bit
rem Install base cygwin
cscript /nologo %DLOAD_SCRIPT% https://cygwin.com/setup-x86_64.exe setup-x86_64.exe
setup-x86_64.exe --no-admin --root %CYGWIN_BASE% --quiet-mode --no-shortcuts --no-startmenu --arch x86_64 --no-write-registry --site https://mirrors.kernel.org/sourceware/cygwin/ -l %CYGWIN_BASE%\var\cache\apt\packages --packages dos2unix,wget
)
)

rem Install apt-cyg package manager
%CYGWIN_BASE%\bin\wget.exe -O %CYGWIN_BASE%\bin\apt-cyg https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg
%CYGWIN_BASE%\bin\chmod.exe +x %CYGWIN_BASE%\bin\apt-cyg
%CYGWIN_BASE%\bin\dos2unix.exe %CYGWIN_BASE%\bin\apt-cyg

rem Create home directory
"%CYGWIN_BASE%\bin\bash.exe" --login -c echo "Creating home directory..."

rem Create desktop shortcut
set SHORTCUT_SCRIPT=%TEMP%\shortcut-%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs
echo Set oWS = WScript.CreateObject("WScript.Shell")                    >  "%SHORTCUT_SCRIPT%"
echo sLinkFile = "%USERPROFILE%\Desktop\Cygwin Terminal.lnk"            >> "%SHORTCUT_SCRIPT%"
echo Set oLink = oWS.CreateShortcut(sLinkFile)                          >> "%SHORTCUT_SCRIPT%"
echo oLink.TargetPath = "%CYGWIN_BASE%\bin\mintty.exe"                  >> "%SHORTCUT_SCRIPT%"
echo oLink.Arguments = "-i /Cygwin-Terminal.ico -"                      >> "%SHORTCUT_SCRIPT%"
echo oLink.IconLocation = "%CYGWIN_BASE%\Cygwin-Terminal.ico,0"         >> "%SHORTCUT_SCRIPT%"
echo oLink.Save                                                         >> "%SHORTCUT_SCRIPT%"
echo Set oWS = WScript.CreateObject("WScript.Shell")                    >  "%SHORTCUT_SCRIPT%"
echo sLinkFile = "%CYGWIN_BASE%\Cygwin Terminal.lnk"            >> "%SHORTCUT_SCRIPT%"
echo Set oLink = oWS.CreateShortcut(sLinkFile)                          >> "%SHORTCUT_SCRIPT%"
echo oLink.TargetPath = "%CYGWIN_BASE%\bin\mintty.exe"                  >> "%SHORTCUT_SCRIPT%"
echo oLink.Arguments = "-i /Cygwin-Terminal.ico -"                      >> "%SHORTCUT_SCRIPT%"
echo oLink.IconLocation = "%CYGWIN_BASE%\Cygwin-Terminal.ico,0"         >> "%SHORTCUT_SCRIPT%"
echo oLink.Save                                                         >> "%SHORTCUT_SCRIPT%"
cscript /nologo "%SHORTCUT_SCRIPT%"
del "%SHORTCUT_SCRIPT%" 

rem Cleanup
del "%DLOAD_SCRIPT%"
del "%SHORTCUT_SCRIPT%"
set CYGWIN_BASE=
set CPU=
set DLOAD_SCRIPT=
set SHORTCUT_SCRIPT=

echo Cygwin is now installed!

:exit
pause
