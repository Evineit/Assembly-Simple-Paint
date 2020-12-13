cdseg segment
;Programa 11.- Pone 2 cuadros de diferente color, en diferente posicion
org 0100h
.code
    mov ah,00h
    mov al,18d
    int 10h
    call pos
    mov ah,09h
    mov al,219d
    mov bh,0d
    mov bl,10d
    mov cx,3d
    int 10h
    call pos2
    mov ah,09h
    mov al,219d
    mov bh,0d
    mov bl,14d
    mov cx,3d
    int 10h
    mov ah,07h
    int 21h
    mov ah,00h
    mov al,3d
    int 10h
    int 20h
pos proc
    mov ah,02h
    mov dl,39d
    mov dh,12d
    mov bh,0d
    int 10h
    ret
    pos endp
pos2 proc
    mov ah,02h
    mov dl,39d
    mov dh,13d
    mov bh,0d
    int 10h
    ret
    pos2 endp