IDEAL

MODEL small

STACK 256

DATASEG

;x dw 0
;y dw 0
sqrX dw 0
sqrY dw 0
sqrXend dw 0
sqrYend dw 0
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
    mov al, 44h
    mov ah, 0ch
    mov cx, [sqrX]
    mov dx, [sqrY]
    add cx, 20
    sub dx, 20
    mov [sqrXend], cx
    mov [sqrYend], dx
    mov cx, [sqrX]
    mov dx, [sqrY]
    ROW:
        int 10h
        inc cx
        cmp cx, [sqrXend]
        JLE ROW
    FULL:
        mov cx, [sqrX]
        sub dx, 1
        cmp dx, [sqrYend]
        JNE ROW
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
DrawRow:
    mov [sqrX], 180
    mov [sqrY], 100
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

