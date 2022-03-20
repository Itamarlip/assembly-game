IDEAL

MODEL small

STACK 256

DATASEG

sqrX dw 0
sqrY dw 0
sqrXend dw 0
sqrYend dw 0
TurnsNum db 30h
endofstr db '$'
color db 15
curPosX dw 0
curPosY dw 0
VeloX dw 0
VeloY dw 0
sideOfShot dw 0
upOrDown dw 1
diffX dw 0
diffY dw 0
turnDone dw 0
amountOfDraws dw 0
rowsOfsqrs dw 0
msg  db  'Rules:                                  --------------------------------------    Aim with your mouse,                    press to shoot the ball.                Your goal is to destroy the squares     before they hit the floor.              The squares will go down once in 3      turns$' ,0 
len  equ  $ - msg            ;length of our dear string

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
    push dx
    mov dx, 0
    mov ax, cx
    mov bx, 2
    div bx
    mov cx, ax
    pop dx
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
    push bx
    push cx
    push dx
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
    pop dx
    pop cx
    pop bx
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
        cmp ax, 80
        jle waiting
    pop ax
    ret
endp

proc left_shoot_up
    mov [color], 44
    sub cx, [VeloX]
    sub dx, [VeloY]
    call color_pixel
    add cx, [VeloX]
    add dx, [VeloY]
    mov [color], 0
    call color_pixel
    sub cx, [VeloX]
    sub dx, [VeloY]
    push cx
    push dx
    mov cx, 160
    mov dx, 190
    mov [color], 3h
    call color_pixel
    pop dx
    pop cx
    ret
endp

proc right_shoot_up
    mov [color], 44
    add cx, [VeloX]
    sub dx, [VeloY]
    call color_pixel
    sub cx, [VeloX]
    add dx, [VeloY]
    mov [color], 0
    call color_pixel
    add cx, [VeloX]
    sub dx, [VeloY]
    inc ax
    push cx
    push dx
    mov cx, 160
    mov dx, 190
    mov [color], 3h
    call color_pixel
    pop dx
    pop cx
    ret
endp

proc left_shoot_down
    mov [color], 44
    sub cx, [VeloX]
    sub dx, [VeloY]
    call color_pixel
    add cx, [VeloX]
    add dx, [VeloY]
    mov [color], 0
    call color_pixel
    sub cx, [VeloX]
    sub dx, [VeloY]
    inc ax
    push cx
    push dx
    mov cx, 160
    mov dx, 190
    mov [color], 3h
    call color_pixel
    pop dx
    pop cx
endp

proc right_shoot_down
    mov [color], 44
    sub cx, [VeloX]
    add dx, [VeloY]
    call color_pixel
    add cx, [VeloX]
    sub dx, [VeloY]
    mov [color], 0
    call color_pixel
    sub cx, [VeloX]
    add dx, [VeloY]
    inc ax
    push cx
    push dx
    mov cx, 160
    mov dx, 190
    mov [color], 3h
    call color_pixel
    pop dx
    pop cx
endp

proc shoot_ball
    push ax
    push bx
    push cx
    push dx
    mov cx, 160
    mov dx, 190
    sides:
        call detecte_collision
        call wait_shot
        cmp [turnDone], 1
        je end_shot
        cmp [sideOfShot], 1
        je rightDec
        jmp leftDec
        leftDec:
            cmp [upOrDown], 0
            je dirleftdown
            jmp dirleftup
        rightDec:
            cmp [upOrDown], 0
            je dirrightdown
            jmp dirrightup
    dirleftup:
        call left_shoot_up
        jmp sides
    dirrightup:
        call right_shoot_up
        jmp sides
    dirleftdown:
        call left_shoot_down
        jmp sides
    dirrightdown:
        call right_shoot_down
        jmp sides
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
    hit_square:
        xor bx, bx
        mov ah, 0Dh
        int 10
        cmp al, 5
        je sqrcoll
        jmp hit_check
        sqrcoll:
            call collision_with_square
            jmp end_coll
    hit_check:
        cmp cx, 3h
        jl hit_left
        cmp cx, 317
        jge hit_right
        cmp dx, 3h
        jle hit_up
        cmp dx, 190d
        jg hit_down
        jmp end_coll
        hit_left:
            mov [sideOfShot], 1
            jmp end_coll
        hit_right:
            mov [sideOfShot], 0
            jmp end_coll
        hit_up:
            mov [upOrDown], 0
            jmp end_coll
        hit_down:
            add [TurnsNum], 1
            mov [turnDone], 1
    end_coll:
        pop bx
        pop ax
    ret
endp

proc calculate_velo
    mov ax, 160
    mov bx, 190
    
    cmp [sideOfShot], 0
    je toTheLeft
    jmp toTheRight
    toTheLeft:
        sub ax, cx
        sub bx, dx
        mov cx, ax
        mov dx, bx
        xor ax, ax
        xor bx, bx
        jmp divideParts
    toTheRight:
        sub cx, ax
        sub bx, dx
        mov dx, bx
        xor ax, ax
        xor bx, bx
    divideParts:
        mov ax, dx
        xor dx, dx
        mov bl, 2
        div bl
        mov dl, al
        mov ax, cx
        div bl
        mov cl, al
        cmp cx, 1
        je end_velo
        cmp dx, 1
        je end_velo
        jmp divideParts
    end_velo:
        mov [VeloX], cx
        mov [VeloY], dx
    ret
endp

proc collision_with_square
    cmp [upOrDown], 0
    je changeup
    jne changedown
    changeup:
        mov [upOrDown], 1
        jmp leftright
    changedown:
        mov [upOrDown], 0
    leftright:
        cmp [sideOfShot], 0
        je changeright
        jne changeleft
    changeleft:
        mov [sideOfShot], 0
        jmp continue_sqr_coll
    changeright:
        mov[sideOfShot], 1
    continue_sqr_coll:

    ret
endp

proc row_down
    push ax
    push bx
    push cx
    push dx
    mov dx, bx
    sub dx, 20
    xor cx, cx
    sub cx, 40
    call row_of_squares
    cmpsqr:
        add [amountOfDraws], 1
        cmp [amountOfDraws], 9
        je end_downraw
        add cx, 40
        push bx
        xor ax, ax
        mov bh, 0
        mov ah, 0Dh
        int 10
        pop bx
        cmp al, 0
        je deletesqr
        jmp cmpsqr
    deletesqr:
        push bx
        xor bx, bx
        mov [sqrX], cx
        mov [sqrY], bx
        mov [color], 0
        call draw_square
        mov [sqrX], 0
        mov [sqrY], 0
        pop bx
        jmp cmpsqr
    end_downraw:
        mov [amountOfDraws], 0
        pop dx
        pop cx
        pop bx
        pop ax
    ret
endp

proc show_score
    mov ah, 02h 
	mov bh, 0 
	mov dh, 01h 
	mov dl, 02h 
	int 10h

	mov ah, 09h 
	lea dx, [TurnsNum]
	int 21h
    ret
endp

proc show_rules
    mov ah, 02h 
	mov bh, 0 
	mov dh, 01h 
	mov dl, 02h 
	int 10h

	mov ah, 09h 
	lea dx, [msg]
	int 21h
    ret
endp

Start:
    mov ax, @data
    mov ds, ax
	call enter_graphic_mode
Rules:
    ;call show_rules
    call Cursor_Position
    ;cmp bx, 1
    ;jne Rules
    call enter_graphic_mode
    xor bx, bx
    call wait_a_sec



    mov cx, 160
    mov dx, 190
    mov [color], 3h
    call draw_ball
    mov [color], 0Fh
    
RowDraw:
    mov [sqrX], 40
    mov [sqrY],0
    mov [color], 5
    xor bx, bx
    call draw_square
    mov bx, 20
    call row_down
    




    call show_score



waitToShot:
    xor bx,bx
    mov [color], 44h
	call Cursor_Position
	;call draw_ball
    ;mov bx, 1
    cmp bx, 1
    je oneShot
    loop waitToShot


oneShot:
    ;mov cx, 200
    ;mov dx, 100
    ;mov [VeloX],2
    ;mov [VeloY],1
    ;mov [sideOfShot], 1
    add [TurnsNum], 1
    call show_score
    call Cursor_Position
    call decide_half
    call calculate_velo
    call shoot_ball

endOfTurn:



Exit:
    mov ax, 4C00h
    int 21h
END start