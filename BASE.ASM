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
    
    mov al, [color]
    mov ah, 0ch
    int 10h
    ret
endp

proc curosr_position
	mov ax, 0003h
	int 33h
    mov ax, cx
    mov bh, 2
    div bh
    mov ch, 0
    mov cl, al
	ret
endp

proc draw_square
    push ax
    push cx
    mov al, [color]
    mov ah, 0ch
    mov cx, [sqrX]
    mov dx, [sqrY]
    add cx, 38
    sub cx, bx
    add dx, 20
    sub dx, bx
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
        inc dx
        cmp dx, [sqrYend]
        JNE ROW
    pop cx
    pop ax
    ret
endp

proc row_of_squares
    DrawRow:
        mov [color], 44h
        xor ax, ax
        xor cx, cx
        mov [sqrY], bx
        xor bx, bx
    OneSqr:
        mov [sqrX], ax
        call draw_square
        add ax, 40
        inc cx
        cmp cx, 8
        JNE OneSqr
    DrawRow1:
        mov [color], 3
        mov ax, 1
        xor cx, cx
        mov bx, 2
        add [sqrY], 1
    OneSqr1:
        mov [sqrX], ax
        call draw_square
        add ax, 40
        inc cx
        cmp cx, 8
        JNE OneSqr1

    ret
endp

proc draw_ball
    call color_pixel
    inc cx
    call color_pixel
    sub cx, 2
    call color_pixel
    inc cx
    inc dx
    call color_pixel
    sub dx, 2
    call color_pixel
    ret
endp



Start:
    mov ax, @data
    mov ds, ax
	call enter_graphic_mode
    mov cx, 155
    mov dx, 190
    mov [color], 3h
    call draw_ball
    mov [color], 0Fh

RowDraw:
    mov bx, 0
    call row_of_squares
    mov bx, 21
    call row_of_squares
    mov bx, 42
    call row_of_squares


ColorCurs:
	call curosr_position
	call draw_ball
    cmp bl, 1
    je Line
    loop ColorCurs
Line:
    sub dx, 200
    inc [TurnsNum]
Exit:
    mov ax, 4C00h
    int 21h
END start

