## Little C Compiler

by Simon Lehmayr

Please read docs for a detailed reference

littleC is a general compiler for the SC61860 CPU, used in several Sharp Pocket Computers, like

PC-1360, PC-1350, PC-1475, PC-1450, PC-1401, PC-1402, PC-1403, PC-1403H, PC-1421, PC-1260, PC-1261

It is composed of three distinct tools:

# lcpp (C pre-compiler)

lcpp will take a list of files as parameters. It will remove and replace preprocessor commands and restructure the code.
The last given file in the list is the output file where the resulting code is put to.

# lcc (C-to-ASM compiler)

lcc will do the main work, which is really amazing because it is just a 30kB executable file :-)
It takes as parameters the input c file and output assembler file.

# pasm (ASM-to-binary compiler)

pasm creates from the assembler file the real machine code to run on your pocket device.

