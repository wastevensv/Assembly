section .data
  userMsg db 'Please enter a number: '
  lenUserMsg equ $-userMsg
  dispMsg db 'You have entered: '
  lenDispMsg equ $-dispMsg

section .bss
  num resb 5            ;Reserve 5 bytes for num

section .text
  global main

  main:
    ;Prompt
    mov eax, 4          ;sys_write
    mov ebx, 1          ;file descriptor (stdout)
    mov ecx, userMsg    ;message
    mov edx, lenUserMsg ;length of message
    int 80h             ;call kernel

    ;Read and store input
    mov eax, 3          ;sys_read
    mov ebx, 2          ;file descriptor (stdin)
    mov ecx, num        ;address to store number
    mov edx, 5          ;length of number (1 byte sign + 4 bytes numeric)
    int 80h             ;call kernel

    ;Output dispMsg
    mov eax, 4          ;sys_write
    mov ebx, 1          ;file descriptor (stdout)
    mov ecx, dispMsg    ;message
    mov edx, lenDispMsg ;length of message
    int 80h             ;call kernel

    ;Output number
    mov eax, 4          ;sys_write
    mov ebx, 1          ;file descriptor (stdout)
    mov ecx, num        ;message
    mov edx, 5          ;length of message
    int 80h             ;call kernel

    ;Exit code
    mov eax, 1          ;sys_exit
    mov ebx, 0          ;exit code (0)
    int 80h             ;call kernel