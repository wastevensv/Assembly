section .data
  snippet db "LOWERCASE"
  len     equ $ - snippet

section .text
  global _start

_start:
  nop

  mov ebx, snippet
  mov eax, len
  .strloop:
    add byte [ebx+eax-1], 32
    dec eax
    jnz .strloop

  nop
