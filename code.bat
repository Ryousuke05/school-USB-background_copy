set "drive_letter=F"
set "target=D:\backups"
set "countdown=10"
set "desktop_folder=seewo"
set ymd=%date:~0,4%-%date:~5,2%-%date:~8,2%





if exist "%userprofile%\desktop\%desktop_folder%" (goto exit)
if exist "%target%\log.txt" (goto start)

:initialize
md "%target%\control"
echo - > "%target%\log.txt"
echo - > "%target%\nolist.txt"

:start
echo - >> "%target%\log.txt"
echo [%ymd% %time%]----------start---------- >> "%target%\log.txt"
md "%userprofile%\desktop\%desktop_folder%"
:main
cls
if exist "%drive_letter%:\nocopy" (
    echo [%ymd% %time%][stop] exist_nocopy >> "%target%\log.txt"
    goto copystop
)

if exist "%target%\control\stop" (
    echo [%ymd% %time%][control] stop >> "%target%\log.txt"
    goto stop
)
if exist "%target%\control\end" (goto end)

if exist "%drive_letter%:\" (
    echo [%ymd% %time%] found %drive_letter% start_countdown[%countdown%] >> "%target%\log.txt"
    goto copy
)
timeout /t %countdown%

goto main

:copy
timeout /t %countdown%

if exist "%drive_letter%:\" (
    echo exist
    ) else (
    echo [%ymd% %time%][exit] disexist %drive_letter%: after countdown[%countdown%] >> "%target%\log.txt"
    goto main
)

for /f "tokens=2 delims==" %%a in ('wmic volume where "DriveLetter='%drive_letter%:'" get SerialNumber /value') do (
    set "serial_number=%%a"
)

if "%serial_number%"=="" (
    echo [%ymd% %time%][err] serial_number=null >> "%target%\log.txt"
    echo - >> "%target%\log.txt"
    goto main
)
findstr "%serial_number%" "%target%\nolist.txt"
if %errorlevel% == 0 (
    echo [%ymd% %time%][already_coped] stoped code:%serial_number% >> "%target%\log.txt"
    goto already_coped
)
echo [%ymd% %time%][copy] started>> "%target%\log.txt"
echo [%ymd% %time%][info] serial_number:%serial_number% target:"%target%\results\%serial_number%\" >> "%target%\log.txt"
xcopy "%drive_letter%:\" "%target%\results\%serial_number%\" /e /v /c /q /g /h /r /y

if %errorlevel% equ 0 (
    echo [%ymd% %time%][copy] sucsess >> "%target%\log.txt"
    echo - >> "%target%\log.txt"
    echo %serial_number%. >> "%target%\nolist.txt"
) else (
    echo [%ymd% %time%][copy] failed_errorlevel:%errorlevel% >> "%target%\log.txt"
)
echo- >> "%target%\log.txt"
goto main

:copystop
if exist "%drive_letter%:\nocopy" (
    timeout /t %countdown%
    goto copystop
)
goto main

:stop
if exist "%target%\control\stop" (
    timeout /t %countdown%
    goto stop
)
goto main

:already_coped
if exist "%drive_letter%:\" (
    timeout /t %countdown%
    goto already_coped
)
echo [%ymd% %time%][continue] %drive_letter% not detected >> "%target%\log.txt"
echo - >> "%target%\log.txt"
goto main

:end
echo [%ymd% %time%][control] end >> "%target%\log.txt"
echo [%ymd% %time%]----------end---------- >> "%target%\log.txt"
echo - >> "%target%\log.txt"
del /f /s /q "%target%\control\end"
rd /s /q "%userprofile%\desktop\%desktop_folder%"

:exit