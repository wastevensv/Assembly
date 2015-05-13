section .text
  global _start     ; must be declared for linker (ld)

; ----- START main -----
_start:             ; tells linker entry point
  push ebp                ; put ebp on the stack
  mov ebp, esp            ; esp is now the bottom of the stack
  cmp dword [ebp + 4], 1  ; check argument count (1st item is always program path)
  je  err_no_args         ; no args entered, dont do anything.

  mov ebx, 4
  mov eax, [ebp + 12]     ; eax now points to the first argument
  call string_to_int      ; parse argument 1 for an integer (returned in eax)
  call word_to_hexstr     ; convert the int (in eax) to a hexadecimal string (stored in outstr)

  mov edx, 5        ; message length
  mov ecx, outstr   ; message to write
  mov ebx, 1        ; file descriptor (stdout)
  mov eax, 4        ; system call number (sys_write)
  int 80h           ; call kernel

exit:
  mov ebx, 0        ; exit code
  mov eax, 1        ; system call number (sys_exit)
  int 80h           ; call kernel
; ----- END main -----

; ----- START string_to_int -----
; - Converts a 4 character numeric string (pointed to by eax)
; - to an interger (returned in eax)
string_to_int:
  mov esi, eax      ; esi points to the start of the string
  add esi, ebx      ; esi now points to the end of the string
  xor eax, eax      ; eax = 0
  mov edx, 1
  .intloop:
    dec esi           ; shift back to next character
    mov cl, [esi]     ; cx contains the character
    and ecx, 0x000f   ; keep only the lowest 4 bits
    imul ecx, edx     ; multiply ecx by edx
    add eax, ecx      ; add ecx to eax
    imul edx, 10      ; multiply edx by 10 (for next digit)
    dec ebx           ; one less digit to loop through
    jnz  .intloop     ; if value is not 0 keep going.
  ret

; ----- END string_to_int -----

; ----- START word_to_hexstr -----
; - Converts a 4 byte word (in eax)
; - to a 4 character, newline terminated string
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

; ----- START err_no_args -----
; - prints error message and exits
err_no_args:
  mov edx, len_no_args  ; message length
  mov ecx, msg_no_args  ; message to write
  mov ebx, 1            ; file descriptor (stdout)
  mov eax, 4            ; system call number (sys_write)
  int 80h               ; call kernel
  jmp exit              ; goto exit
; ----- END err_no_args -----

section .data
  hexstr          db '0123456789ABCDEF'   ; Hex to character mapping
  num             dw 4243                 ; Number to convert
  msg_no_args     db 'No number provided',10
  len_no_args equ $-msg_no_args

section .bss
  outstr resb 5     ; Reserve 5 bytes for num (4 nibbles + newline)
