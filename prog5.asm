;Programa 5.- Enciende un PIXEL en la posición del click izquierdo (simulación LAPIZ)

name test

CSEG    SEGMENT     ; code segment starts here.
org 0100h
col dw ?
ren dw ?

.code
ponpix macro c,r ;Macro que recibe dos parámetros, en C y en R
 mov ah,0Ch ;Funcion 12d=0Ch para pintar o desplegar PIXEL
 mov al,00001010b ;AL=Atributos de color, parte baja: 1010b=10d=Color Verde (vea Paleta de Color)
;  mov cx,c ;Cx=Columna donde se despliega PIXEL (empieza desde cero)
;  mov dx,r ;Dx=Renglon donde se despliega PIXEL (empieza desde cero)
 int 10h ;INT 10H funcion 0CH, despliega PIXEL de color en posicion CX (Columna), DX (Renglon)
endm
;Inicio del Programa Principal
call inigraf ;Llama al procedimiento para iniciar graficos
etip:
call prende ;Llama al procedimiento para prender el raton
eti0:
    mov ax,3d
    int 33h ;Detecta coordenadas y boton oprimido
    cmp bx,0d
    je etip ;Mientras NO se oprima ningun boton, se cicla
    cmp bx,1d
    jne fin ;El programa termina si se oprime el boton derecho o los 2 botones
    mov col,cx ;Carga en COL el valor de la columna
    mov ren,dx ;Carga en REN el valor del renglon
    call apaga ;Llama al procedimiento APAGA para apagar el raton
    ponpix col,ren ;Llama a la macro PONPIX para desplegar PIXEL
    ; call prende ;Llama al procedimiento PRENDE para prender el raton
    jmp eti0 ;Salta incondicionalmente a ETI0 y se cicla para esperar a que se oprima un boton
    
fin:
 call apaga ;Apaga raton
 call cierragraf ;Cierra graficos
 int 20h ;Termina el programa

;Inicia Zona de Procedimientos
prende proc
 mov ax,1d
 int 33h
 ret
apaga proc
 mov ax,2d
 int 33h
 ret
inigraf proc
 mov ah,0d
 mov al,18d
 int 10h
 ret
cierragraf proc
 mov ah,0d
 mov al,3d
 int 10h
 ret 
