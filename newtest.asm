;Programa 12.- Termina el programa unicamente cuando se da click izquierdo sobre la cadena SALIR
CSEG    SEGMENT     ; code segment starts here.
org 0100h
col dw ?
ren dw ?
bot dw ?
co db ?
re db ?
numero macro num
 mov ax,num
 mov bl,100d
 div bl
 mov dl,al
 add dl,30h
 push ax
 mov ah,02h
 int 21h
 pop ax
 shr ax,8
 mov bl,10d
 div bl
 mov dl,al
 add dl,30h
 push ax
 mov ah,02h
 int 21h
 pop ax
 shr ax,8 
 mov dl,al
 add dl,30h
 mov ah,02h
 int 21h
 endm
;Inicia Programa Principal
.code
jmp inicio
 cad db 'SALIR$'
inicio:
    mov ah,00h
    mov al,18d
    int 10h
    mov co,37d
    mov re,11d
    call pos
    mov ah,09h
    lea dx,cad
    int 21h
    mov ax,1d
    int 33h
eti0:
 mov ax,3d
 int 33h
 mov col,cx
 mov ren,dx
 mov bot,bx
 mov co,65d
 mov re,3d
 call pos
 numero col
 mov ah,02h
 mov dl,' ' ;Mover a DL un espacio en blanco
 int 21h
 numero ren
 cmp bot,1d
 jne eti0
 cmp col,297d
 jb eti0 ;JB=Jump if Below (Brinca si esta abajo)
 cmp col,334d
 ja eti0 ;JA=Jmp if Above (Brinca si esta arriba)
 cmp ren,175d
 jb eti0
 cmp ren,186d
 ja eti0
mov ah,00h
mov al,3d
int 10h
int 20h
pos proc
 mov ah,02h
 mov dl,co
 mov dh,re
 mov bh,0d
 int 10h
 ret