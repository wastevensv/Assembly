; boot.asm
; Prints 'Hello World' on boot.

; BiosPrint Macro
%macro BiosPrint 1
    mov si, word %1
ch_loop:
    lodsb
    or al, al
    jz done
    mov ah, 0x0E
    int 0x10
    jmp ch_loop
done:
%endmacro

; Main Routine
[ORG 0x7c00]
    xor ax, ax ; make ax 0
    mov ds, ax

    BiosPrint msg

; Nothing left to do.
hang:
    jmp hang

; Data
msg db 'Hello World', 13, 10, 0

    times 510-($-$$) db 0
    db 0x55
    db 0xAA
