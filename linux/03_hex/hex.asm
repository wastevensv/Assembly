section .text
  global main       ; must be declared for linker (ld)

; ----- START main -----
main:               ; tells linker entry point
  mov eax, [num]
  call word_to_hexstr
  mov edx, 5        ; message length
  mov ecx, outstr   ; message to write
  mov ebx, 1        ; file descriptor (stdout)
  mov eax, 4        ; system call number (sys_write)
  int 80h           ; call kernel

  mov ebx, 0        ; exit code
  mov eax, 1        ; system call number (sys_exit)
  int 80h           ; call kernel
; ----- END main -----

; ----- START word_to_hexstr -----
; - Converts a 2 byte word (in ax) to a 4 character, newline terminated string
word_to_hexstr:
  mov edi, outstr
  mov esi, hexstr
  mov cx, 4
  .hexloop:
    rol ax, 4                 ; rotate 4 bits to the left
    mov ebx, eax              ; copy ax to bx
    and ebx, 0x000f           ; only use the last 4 bits
    mov bl, [esi + ebx]       ; use to pick a character from the hex string
    mov [edi], bl             ; store result in outstr (pointed to by DI)
    inc edi                   ; shift to the next space in DI
    dec cx                    ; 1 less nibble to check
    jnz .hexloop              ; repeat loop till no more nibbles
  mov ebx, 10                 ; add newline character...
  mov [edi], ebx              ; ... to the end of the string
  ret                         ; return
; ----- END word_to_hexstr -----


section .data
  hexstr    db '0123456789ABCDEF'   ; Hex to character mapping
  num       dw 4243                 ; Number to convert

section .bss
  outstr resb 5     ; Reserve 5 bytes for num (4 nibbles + newline)
