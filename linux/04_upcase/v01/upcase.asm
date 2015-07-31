; Executable name : upcase
; Version         : 01
; Created         : 2015-07-12 (July 12th 2015)
; Modified        : 2015-07-30 (July 30th 2015)
; Author          : William Stevens (based on code by Jeff Duntemann)
; Description     : A utility to convert all ASCII lowercase characters to uppercase,
;                   and all nonprintable characters to space (20h). Also used as a practice in procedures and commenting.
;
; Build instructions:
;   # nasm -g -f elf -o $(OBJ) $(SRC)
;   # ld -s -m elf_i386 -o $(TARGET) $(OBJ)

SECTION .bss        ; Uninitialized data
    READLEN     equ 1024        ; Length of buffer
    ReadBuffer: resb READLEN    ; Text buffer

SECTION .data       ; Initialized data
    StatMsg: db "Processing...",10
    StatLen: equ $-StatMsg
    DoneMsg: db "...done",10
    DoneLen: equ $-DoneMsg

    ; Translation table:
    ;   non-printable characters to space
    ;     (except LF (0Ah) or HT (09h)
    ;   all lowercase characters to uppercase
    ;   all uppercase characters as themselves
    UpCase:
      db 20h,20h,20h,20h,20h,20h,20h,20h,20h,09h,0Ah,20h,20h,20h,20h,20h
      db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
      db 20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh
      db 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh
      db 40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
      db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh
      db 60h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
      db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,7Bh,7Ch,7Dh,7Eh,20h
      db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
      db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
      db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
      db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
      db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
      db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
      db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
      db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h

SECTION .text       ; Program Code

global _start
; ----- BEGIN MAIN PROCEDURE -----
_start:
    ;Display status message
      mov eax, 4              ; System call 4: sys_write
      mov ebx, 2              ; File descriptor 2: Standard Error
      mov ecx, StatMsg        ; Status message location
      mov edx, StatLen        ; Status message length
      int 80h                 ; Print Status message

    ; Fill input buffer with text
    read:
      mov eax, 3              ; System call 3: sys_read
      mov ebx, 0              ; File descriptor 0: Standard Error
      mov ecx, ReadBuffer     ; Buffer location
      mov edx, READLEN        ; Buffer length
      int 80h                 ; Read input buffer

      mov ebp, eax            ; Copy return value of sys_read 
      cmp eax, 0              ; If return value is 0, reached EOF
      je done                 ; Jump to end if equal to 0

    ; Setup registers for translations
      mov ebx, UpCase         ; Place the offset of the table into ebx
      mov edx, ReadBuffer     ; Place the offset of the buffer into edx
      mov ecx, ebp            ; Place the number of bytes in the buffer into ecx

    ; translate characters
    translate:
      xor eax, eax            ; Clear eax
      mov al, byte [edx+ecx]  ; Load character into 
      xlat                    ; translate character in AL using table
                              ; Equivilant to "mov al, [ebx+eax]"
      mov byte [edx+ecx], al  ; Put the translated character back in the buffer
      dec ecx                 ; Decement character count
      jnz translate           ; If characters left (ecx!=0), repeat

    ; Write the translated text to stdout
    write:
      mov eax, 4              ; System call 4: sys_write
      mov ebx, 1              ; File descriptor 1: Standard output
      mov ecx, ReadBuffer     ; Buffer location
      mov edx, ebp            ; Buffer length
      int 80h                 ; Print buffer contents

      jmp read                ; Loop back to read another buffer full

    ; Display done message
    done:
      mov eax, 4              ; System call 4: sys_write
      mov ebx, 2              ; File descriptor 2: Standard Error
      mov ecx, DoneMsg        ; Status message location
      mov edx, DoneLen        ; Status message length
      int 80h

    ; Exit
      mov eax, 1              ; System call 1: Exit
      mov ebx, 0              ; Return code 0 (Sucess)
      int 80h                 ; Exit
; ------ END MAIN PROCEDURE ------
