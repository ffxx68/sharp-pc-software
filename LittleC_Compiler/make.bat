@echo off
echo Preprocessing...
lcpp %1 .\tmp.c  && (
	  echo lcpp was successful
	) || (
	  echo lcpp has failed
	)
echo.
if %errorlevel% equ 0 (
	echo Compiling...
	lcc .\tmp.c .\tmp.asm && (
	  echo lcc was successful
	) || (
	  echo lcc has failed
	)
)
echo.
if %errorlevel% equ 0 (
	echo Assembling...
	pasm .\tmp.asm %2 %3 && (
	  echo pasm was successful
	) || (
	  echo pasm has failed
	)
)
echo.
if %errorlevel% equ 0 (
	echo OK - Done!
) else (
	echo ** ERRORS! **
)
