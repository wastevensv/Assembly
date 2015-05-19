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
    dec eax
    add byte [ebx+eax], 32
    cmp eax,0
    jnz .strloop

  nop
