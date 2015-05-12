# Linux Assembly Language

## Assemble with debugging (for GDB)):
`
$ nasm -g -f elf -o [file].o [file].asm
$ ld -ggdb -m elf_i386 -o [file] [file].o
`

## Assemble without debugging:
`
$ nasm -f elf -o [file].o [file].asm
$ ld -m elf_i386 -o [file] [file].o
`