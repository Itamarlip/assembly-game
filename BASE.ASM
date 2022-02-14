IDEAL

MODEL small

STACK 256

DATASEG

sqrX dw 0
sqrY dw 0
sqrXend dw 0
sqrYend dw 0
TurnsNum db 0
color db 15
curPosX dw 0
curPosY dw 0
VeloX dw 0
VeloY dw 0
sideOfShot dw 0
diffX dw 0
diffY dw 0



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
    push ax
    mov al, [color]
    mov ah, 0ch
    int 10h
    pop ax
    ret
endp

proc Cursor_Position
	mov ax, 0003h
	int 33h
    push bx
    mov ax, cx
    mov bh, 2
    div bh
    mov ch, 0
    mov cl, al
    pop bx
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
        mov [color], 5
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
    inc dx
    ret
endp

proc wait_a_sec 
    push ax
    push bx
    push cx
    push dx
    mov ah,2Ch
    int 21h
    mov bl,dl
    cmp bl, 50
    jle less_50
    jmp great_50
    less_50:
        add bl, 50
        mov ah,2Ch
        int 21h
        cmp dl, bl
        jle less_50
        jmp end_sec
    great_50:
        mov cl, 50
        sub cl, bl
        mov ah,2Ch
        int 21h
        cmp ah, cl
        jle great_50
    end_sec:
        pop dx
        pop cx
        pop bx
        pop ax
    ret
endp 

proc wait_shot
    push ax
    xor ax, ax
    waiting:
        call wait_a_sec
        inc ax
        cmp ax, 120
        jle waiting
    pop ax
    ret
endp

proc shoot_ball
    push ax
    push bx
    push cx
    push dx
    xor ax, ax
    mov cx, 160
    mov dx, 190
    cmp [sideOfShot], 1
    je dirright
    dirleft:
        mov [color], 44
        sub cx, [VeloX]
        sub dx, [VeloY]
        call draw_ball
        add cx, [VeloX]
        add dx, [VeloY]
        mov [color], 0
        call draw_ball
        sub cx, [VeloX]
        sub dx, [VeloY]
        inc ax
        push cx
        push dx
        mov cx, 160
        mov dx, 190
        mov [color], 3h
        call draw_ball
        call wait_shot
        pop dx
        pop cx
        call detecte_collision
        cmp ax, 70
        jle dirleft
        jmp end_shot
    dirright:
        mov [color], 44
        add cx, [VeloX]
        sub dx, [VeloY]
        call draw_ball
        sub cx, [VeloX]
        add dx, [VeloY]
        mov [color], 0
        call draw_ball
        add cx, [VeloX]
        sub dx, [VeloY]
        inc ax
        push ax
        xor ax, ax
        pop ax
        push cx
        push dx
        mov cx, 160
        mov dx, 190
        mov [color], 3h
        call draw_ball
        call wait_shot
        pop dx
        pop cx
        call detecte_collision
        cmp ax, 70
        jle dirright
    end_shot:
        pop dx
        pop cx
        pop bx
        pop ax
    ret
endp

proc decide_half
    push bx
    cmp cx, 160
    jle change0
    jmp change1
    change0:
        mov [sideOfShot], 0
        jmp end_dec
    change1:
        mov [sideOfShot], 1
    end_dec:
        pop bx
    ret
endp

proc detecte_collision
    push ax
    push bx
    cmp cx, 10
    jle hit_left
    cmp cx, 310
    jge hit_right
    jmp end_coll
    hit_left:
        mov [sideOfShot], 1
        jmp end_coll
    hit_right:
        mov [sideOfShot], 0
    end_coll:
        pop bx
        pop ax
    ret
endp

proc calculate_velo
    call Cursor_Position
    mov [curPosX], cx
    mov [curPosY], dx
    mov cx, 160
    mov dx, 190
    sub cx, [curPosX]
    mov [diffX], cx
    cmp cx, [curPosX]
    jl negative
    negative:
        mov [sideOfShot], 1
    sub dx, [curPosY]
    mov [diffY], dx
    call draw_ball
    ret
endp


Start:
    mov ax, @data
    mov ds, ax
	call enter_graphic_mode
    mov cx, 160
    mov dx, 190
    mov [color], 3h
    call draw_ball
    mov [color], 0Fh

RowDraw:
    mov bx, 0
    call row_of_squares


ColorCurs:
    xor bx,bx
    mov [color], 44h
	call Cursor_Position
	;call draw_ball
    cmp bx, 1
    je Line
    loop ColorCurs


Line:
    mov [VeloX], 3
    mov [VeloY], 3
    call decide_half
    call shoot_ball





    call calculate_velo




Exit:
    mov ax, 4C00h
    int 21h
END start

