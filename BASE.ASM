IDEAL

MODEL small

STACK 256

DATASEG

;x dw 0
;y dw 0
sqrx dw 0
sqry dw 0
TurnsNum db 0
color db 15

CODESEG


proc enter_graphic_mode
    mov ax, 13h
    int 10h
    ret
endp

proc enter_text_mode
    mov ah, 0
    mov al, 2
    int 10h
    ret
endp

proc color_pixel
    push bx
    push cx
    push dx

    mov bh, 0h 
;    mov cx, [x]
;    mov dx, [y]
    mov al, [color]
    mov ah, 0ch 
    int 10h

    pop dx
    pop cx
    pop bx
    ret
endp

proc curosr_position
	mov ax, 0003h
	int 33h
	ret
endp

proc draw_square 
    push ax
    mov [color], 44h
    mov ax, [sqrx]
    add ax, 20
    mov bx, [sqry]
    sub bx, 20
    mov cx, [sqrx]
    mov dx, [sqry]
ROW:
    call color_pixel
    inc cx
    cmp ax,cx
    jne ROW
FULL:
    dec dx
    jmp ROW
    cmp dx, bx
    jne FULL
    ret
endp

proc calc_line
    push bx
    push cx
    push dx
    mov cx,cx
    pop dx
    pop cx
    pop dx
endp

Start:
    mov ax, @data
    mov ds, ax
	call enter_graphic_mode
    mov [sqrx], 180
    mov [sqry], 100
    call draw_square
ColorCurs:
    xor bx,bx
	call curosr_position
	call color_pixel
    cmp bl, 1
    je continue
    loop ColorCurs
continue:
    inc [TurnsNum]
Exit:
    mov ax, 4C00h
    int 21h
END start

