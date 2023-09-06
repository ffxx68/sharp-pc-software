@echo of
call yasm -d petools.bas  -f compact -s 5000 -i 10 petools.asm
call yasm -d petools2.bas -f compact -s 10000 -i 10 petools2.asm
call yasm -d serext.bas -f compact -s 15000 -i 10 serext.asm
call yasm -d serstub.bas -f compact -s 15000 -i 10 serstub.asm
copy loader.bas+petools.bas+petools2.bas+serstub.bas+loader2.bas peload.bas
copy loader.bas+petools.bas+petools2.bas+serext.bas+loader2.bas peloadse.bas
