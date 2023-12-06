@echo off
echo Preprocessing...
lcpp "%1" tmp.c
echo.
echo Compiling...
lcc tmp.c tmp.asm
echo.
echo Assembling...
pasm tmp.asm tmp.bin %2
echo.
echo Transferring...
wintr 1 tmp.bin
echo.
rem echo Clean up...
rem del tmp.asm
rem del tmp.bin
rem del tmp.c
rem echo.
