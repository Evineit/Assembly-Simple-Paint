set BuildFile=%1
@REM set BuildPath=%2
.\uasm32.exe -1 -DBuildDOS=1 -DDosVGA=1 -bin -Fl"listing.txt" -Fo "prog.exe" %BuildFile%
copy "C:\Users\kevin\Google Drive\ITD\5to\Lenguajes de interfaz\ProjectoGraficos\prog.exe" "C:\8086\"
copy "C:\Users\kevin\Google Drive\ITD\5to\Lenguajes de interfaz\ProjectoGraficos\imagen.bmp" "C:\8086\"
"C:\Program Files (x86)\DOSBox-0.74\DOSBox.exe" prog.exe -noconsole