section .data
  hexstr          db '0123456789ABCDEF'   ; Hex to character mapping
  num             dw 4243                 ; Number to convert
  msg_no_args     db 'No number provided',10
  len_no_args     equ $-msg_no_args
  outstr          db " 00 00 00 00",10
  outlen          equ $-outstr

section .bss
;  outstr resb 9     ; Reserve 5 bytes for num (4 nibbles + newline)

section .text
  global _start     ; must be declared for linker (ld)

; ----- START main -----
_start:             ; tells linker entry point

  ; Place the address of the first command line argument in eax.
  push ebp                ; put ebp on the stack
  mov ebp, esp            ; esp is now the bottom of the stack
  cmp dword [ebp + 4], 1  ; check argument count (1st item is always program path)
  je  err_no_args         ; no args entered, dont do anything.
  mov eax, [ebp + 12]     ; eax now points to the first argument
  
  ; Convert the string in eax to hex string.
  call str_len            ; find the length of the string in eax (returned in ebx)
  call string_to_int      ; parse argument 1 for an integer (returned in eax)
  call word_to_hexstr     ; convert the int (in eax) to a hexadecimal string (stored in outstr)

  ; Print the output.
  mov edx, outlen   ; message length
  mov ecx, outstr   ; message to write
  mov ebx, 1        ; file descriptor (stdout)
  mov eax, 4        ; system call number (sys_write)
  int 80h           ; call kernel

exit:
  mov ebx, 0        ; exit code
  mov eax, 1        ; system call number (sys_exit)
  int 80h           ; call kernel
; ----- END main -----

; ----- START str_len -----
; - Takes a string (pointed to by eax)
; - Retuns its length as an integer (in ebx)
str_len:
  push eax          ; preserve eax in stack
  push ecx          ; preserve ecx in stack
  push edi          ; preserve edi in stack

  ; Set parameters to search the string.
  mov edi, eax      ; edi points to the start of the string
  xor eax, eax      ; eax = 0 (NUL terminated string)
  xor ecx, ecx      ; ecx = 0
  not ecx           ; ecx = -1 (2s compliment) (not x = abs(x)-1)
  
  ; Search the string pointed to by edi for the value in al (0)
  cld               ; clear direction flag (search forward)
  repne scasb       ; search string for value in al (0 or NUL) (increment ecx each pass)
  not ecx           ; ecx was -length-2, (not x = abs(x)-1), ecx is now length+1
  dec ecx           ; ecx is now string length

  mov ebx, ecx      ; ebx is now string length
  
  pop edi           ; return edi to original state
  pop ecx           ; return ecx to original state
  pop eax           ; return eax to original state
  ret
; ----- END str_len -----

; ----- START string_to_int -----
; - Takes a numeric string (pointed to by eax) and its length (in ebx)
; - Returns the strings value (in eax)
string_to_int:
  mov esi, eax      ; esi points to the start of the string
  add esi, ebx      ; esi now points to the end of the string
  xor eax, eax      ; eax = 0
  mov edx, 1        ; edx = place multiplier (1s-place)
  ; intloop - Loops from last character (ones place) to first character
  .intloop:
    dec esi           ; shift back to next character
    mov cl, [esi]     ; cl contains current character in ascii
    and ecx, 0x000f   ; keep only the lowest 4 bits (0x0034 = 4)
    imul ecx, edx     ; multiply ecx by edx
    add eax, ecx      ; add ecx to eax
    imul edx, 10      ; multiply edx by 10 (for next place multiplier)
    dec ebx           ; one less digit to loop through
    jnz  .intloop     ; if value is not 0 keep going.
  ret
; ----- END string_to_int -----

; ----- START word_to_hexstr -----
; - Converts a 4 byte word (in eax)
; - to a 8 character, newline terminated string
word_to_hexstr:
  mov edi, outstr             ; edi points to the position of the output template
  mov esi, hexstr             ; esi points to the start of the hex lookup table
  xor ecx, ecx                ; ecx points to offset in output
  
  ; hexloop - loops from least signifcant bits to most significant bits
  .hexloop:
    ; Convert the first nibble in the byte
    inc ecx
    rol eax, 4                ; rotate 4 highest bits to the low end
    mov ebx, eax              ; copy ax to bx
    and ebx, 0x000f           ; only use the low 4 bits
    mov bl, [esi + ebx]       ; use ebx to pick a character from the hex string (at esi)
    mov [edi+ecx], bl         ; store result in outstr (pointed to by edi)
    
    ; Convert the second nibble in the byte
    inc ecx
    rol eax, 4                ; rotate 4 highest bits to the low end
    mov ebx, eax              ; copy ax to bx
    and ebx, 0x000f           ; only use the low 4 bits
    mov bl, [esi + ebx]       ; use ebx to pick a character from the hex string (at esi)
    mov [edi+ecx], bl         ; store result in outstr (pointed to by edi)
    
    ; move on to the next byte
    inc ecx                   ; shift to the next space in output
    cmp ecx, outlen-1         ; Check if we have reached the end.
    jna .hexloop              ; repeat loop till no more nibbles (cx=outlen)
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
