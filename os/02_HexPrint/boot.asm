; boot.asm
; Prints memory contents to screen in hex

; Main Routine
[ORG 0x7c00]
    mov ax,3
    int 0x10

    mov ax,0x1003
    mov bx,0
    int 0x10

    xor ax, ax          ; AX = 0
    mov ds, ax          ; DS = 0
    mov ss, ax          ; stack start at 0
    mov sp, 0x9c00      ; stack pointer = (7c00h (code start) + 2000h = 9c00h)

    mov ax, 0xb800      ; AX = start of text video memory
    mov es, ax          ; ES = AX
    mov di, 0           ; DI (offset) = 0
    call clearscr       ; clear the screen
    

    mov ax, 0xb800      ; AX = start of text video memory
    mov es, ax          ; ES = AX
    mov si, msg         ; SI points to msg data
    call sprint         ; print string

    mov ax, 0xb800 
    mov gs, ax
    mov bx, 0x0000          ; BX = 0
    mov ax, [gs:bx]         ; AX = First character on screen (W)

    mov word [reg16], ax    ; Store AX in reg16 for printreg16
    call printreg16         ; Print AX to screen as hex

    mov si, vals        ; SI points to start of vals
    lodsw               ; Load next word into AX from memory at SI then increment SI by 2
    printvals:
        push si                 ; Preserve SI in stack
        mov word [reg16], ax    ; Store AX in reg16 for printreg16
        call printreg16         ; Print AX to screen as hex
        pop si                  ; Recall SI from stack
        lodsw                   ; Load next word into AX from memory at SI then increment SI by 2
        cmp ax, 0               ; If AX is not 0 (end of array)...
        jne printvals           ; Then repeat.
    
    hang:
        jmp hang            ; nothing left, just hang

; --------------
; Printing Functions
; --------------

clearscr:
    mov ah, 0x0F
    mov al, ' '             ; AX is white on black ' ' (space)
    stosw                   ; write AX to screen [ES:DI]
    cmp di, 0x0FA0          ; 0x0FA0 = length of video memory
    jne clearscr            ; if not at limit go back to begining
    ret

dochar: call cprint         ; call character printing routine

sprint:
    lodsb                   ; iterate through string
    cmp al, 0               ; if AL (next character) is not 0...
    jne dochar              ; print the character
    add byte [ypos], 1      ; down one row
    mov byte [xpos], 0      ; back to left
    ret

cprint:
    mov ah, 0x0F            ; attrib = white on black
    mov cx, ax              ; save char/attrib
    movzx ax, byte [ypos]   ; ax = ypos
    mov dx, 160             ; 160 bytes per row
    mul dx                  ; 
    movzx bx, byte [xpos]   ; bx = xpos
    shl bx, 1               ; bitshift 1 (bx*2)
    
    mov di, 0               ; start off video memory
    add di, ax              ; add y offset
    add di, bx              ; add x offset

    mov ax, cx              ; restore char/attrib
    stosw                   ; write char/attrib (AX) to screen [ES:DI]
    add byte [xpos], 1      ; advance right 1

    ret

; ---------------
; Hex printing function
; ---------------

printreg16:
    mov di, outstr16        ; DI points to outstr16
    mov ax, [reg16]         ; fill AX with memory location
    mov si, hexstr          ; SI points to the first character of hexstring
    mov cx, 4               ; 4 nibbles (16 bits) to check
hexloop:
   rol ax, 4                ; rotate 4 bits to the left
   mov bx, ax               ; copy ax to bx
   and bx, 0x0f             ; only use the last 4 bits
   mov bl, [si + bx]        ; use to pick a character from the hex string
   mov [di], bl             ; store result in outstr16 (pointed to by DI)
   inc di                   ; shift to the next space in DI
   dec cx                   ; 1 less nibble to check
   jnz hexloop              ; repeat loop till no more nibbles
 
   mov si, outstr16         ; si now points to finished string
   call sprint
 
   ret

; -------------
; Variables
; -------------


xpos                db 0
ypos                db 0
hexstr              db '0123456789ABCDEF'   ; Hex to character mapping
outstr16            db '0000', 0            ; Holds register value string
reg16               dw 0                    ; Used to pass values to printreg16
msg                 dw "What are you doing, Dave?", 0
vals                dw 0x0105, 0x0001, 0x0002 ,0x0004, 0x0008 , 0x0010, 0x0006, 0
times   510-($-$$)  db 0
db 0x55
db 0xAA
