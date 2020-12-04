set BuildFile=%1
@REM set BuildPath=%2
.\uasm32.exe -DBuildDOS=1 -DDosVGA=1 -bin -Fl"listing.txt" -Fo "prog.exe" %BuildFile%
"C:\Program Files (x86)\DOSBox-0.74\DOSBox.exe" .\prog.exe