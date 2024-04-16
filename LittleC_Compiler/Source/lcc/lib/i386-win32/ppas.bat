@echo off
SET THEFILE=C:\Users\f.fumi\Dropbox\sharp PC 1403\Little C Compiler\lcc_b1\Source\lcc\lib\i386-win32\lcc.exe
echo Linking %THEFILE%
C:\Users\f.fumi\lazarus\fpc\3.2.2\bin\x86_64-win64\ld.exe -b pei-i386 -m i386pe  --gc-sections  -s  --entry=_mainCRTStartup    -o "C:\Users\f.fumi\Dropbox\sharp PC 1403\Little C Compiler\lcc_b1\Source\lcc\lib\i386-win32\lcc.exe" "C:\Users\f.fumi\Dropbox\sharp PC 1403\Little C Compiler\lcc_b1\Source\lcc\lib\i386-win32\link1656.res"
if errorlevel 1 goto linkend
C:\Users\f.fumi\lazarus\fpc\3.2.2\bin\x86_64-win64\postw32.exe --subsystem console --input "C:\Users\f.fumi\Dropbox\sharp PC 1403\Little C Compiler\lcc_b1\Source\lcc\lib\i386-win32\lcc.exe" --stack 16777216
if errorlevel 1 goto linkend
goto end
:asmend
echo An error occurred while assembling %THEFILE%
goto end
:linkend
echo An error occurred while linking %THEFILE%
:end
