cdseg segment
;Programa 8.- Dibuja un CUADRO empezando en la posicion del boton izquierdo, hasta la posición del botón derecho
;NOTA: El primer punto (con el Boton Izquierdo ) debe ser el Superior Izquierdo, y el Segundo punto (con el Boton
;Dereho) debe ser el Inferior Derecho
org 0100h
col1 dw ?
ren1 dw ?
col2 dw ?
ren2 dw ?
.code
    mov ah,00h ;Inicio del Programa Principal
    mov al,18d
    int 10h
    mov ax,1d
    int 33h
eti0:
    mov ax,3d
    int 33h
    cmp bx,1d
    jne eti0 ;Este ciclo (ETI0) solo termina si se oprime el botón Izquierdo
    mov col1,cx
    mov ren1,dx
eti1:
    mov ax,3d
    int 33h
    cmp bx,2d
    jne eti1 ;Este ciclo (ETI1) solo termina si se oprime el botón Derecho
    mov col2,cx
    mov ren2,dx
    ; Esto esconde el raton
    ; mov ax,2d
    ; int 33h
    call cuadro
    ; Regresa depues de dibujar un cuadro para seguir poniendo mas
    jmp eti0
    mov ah,07h
    int 21h
    mov ah,00h
    mov al,3d
    int 10h
    int 20h ;Fin del Programa Principal
cuadro proc
    mov cx,col1
    mov dx,ren1
    eti2: ;Inicia proceso para dibujar linea superior horizontal
    mov ah,0ch
    mov al,15d
    int 10h
    inc cx
    cmp cx,col2
    jbe eti2 ;JBE=Jump if Below or Equal (Salta si esta abajo, o si es Igual)

    mov cx,col1
    mov dx,ren2
    eti3: ;Inicia proceso para dibujar linea inferior horizontal
    mov ah,0ch
    mov al,15d
    int 10h
    inc cx
    cmp cx,col2
    jbe eti3

    mov cx,col1
    mov dx,ren1
    eti4: ;Inicia proceso para dibujar linea izquierda vertical
    mov ah,0ch
    mov al,15d
    int 10h
    inc dx
    cmp dx,ren2
    jbe eti4

    mov cx,col2
    mov dx,ren1
    eti5: ;Inicia proceso para dibujar linea derecha vertical
    mov ah,0ch
    mov al,15d
    int 10h
    inc dx
    cmp dx,ren2
    jbe eti5
    ret
    cuadro endp