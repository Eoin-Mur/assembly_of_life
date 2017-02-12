# assembly_of_life

Implemntation of conways game of life ( https://en.wikipedia.org/wiki/Conway's_Game_of_Life ) in the 8086 instruction set using the nasm assembler 

## To Run
nasm -f elf -F dwarf -g life.asm # the -F and -g options are just used for writing the symbols for gdb 
ld -m elf_i386 -o life life.o
./life
