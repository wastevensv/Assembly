# Barebones Assemble Language

## Creating boot image:
`
nasm boot.asm -f bin -o boot.bin
`

## Writing boot image to floppy disc:
`
dd if=boot.bin of=/dev/fd0 # Only needed if booting off of an actual floppy disc.
`