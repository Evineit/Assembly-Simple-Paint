@echo off 

if not exist \Emu\DosBox\DOSBoxPortable.exe goto EmulatorFail

set BuildFile=%1
set BuildPath=%2
if exist \utils\SelectedBuildFile.bat call \utils\SelectedBuildFile.bat 
cd %BuildPath%
if not %BuildPath:~0,1%==%CD:~0,1% goto InvalidPath

\Utils\uasm\uasm32.exe -DBuildDOS=1 -DDosVGA=1 -mz -Fl"\BldX86\listing.txt" -Fo "\RelX86\prog.exe" %BuildFile%

if not "%errorlevel%"=="0" goto Abandon

\Emu\DosBox\DOSBoxPortable.exe -noconsole
rem R:\Emu\DosBox\App\DOSBox\DOSBox.exe

goto Abandon
:InvalidPath
echo Error: ASM file must be on same drive as devtools 
echo File: %BuildPath%\%BuildFile% 
echo Devtools Drive: %CD:~0,1% 
goto Abandon
:EmulatorFail
echo Error: Can't find \Emu\DosBox\DOSBoxPortable.exe
:Abandon
if "%3"=="nopause" exit
pause
