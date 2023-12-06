@echo off
echo Preprocessing...
lcpp "%1" tmp.c
echo.
echo Compiling...
lcc tmp.c tmp.asm
echo.
echo Assembling...
pasm tmp.asm "%2" %3
echo.
rem echo Clean up...
rem del tmp.asm
rem del tmp.c
rem echo.
