set BuildFile=%1
@REM UASM32.exe and dosbox required
.\uasm32.exe -1 -DBuildDOS=1 -DDosVGA=1 -bin -Fl"listing.txt" -Fo "prog.com" %BuildFile%
"%ProgramFiles(x86)%\DOSBox-0.74\DOSBox.exe" "%CD%\prog.com" -noautoexec -noconsole