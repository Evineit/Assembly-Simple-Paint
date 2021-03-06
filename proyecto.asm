CSEG    SEGMENT     ; code segment starts here.
    org 100h
    jmp eti0
;Zona de declaracion de Cadenas e Identificadores creados por el usuario (variables)
.data
cad db 'Error, archivo no encontrado!...presione una tecla para terminar.$'
filename db "C:\imagen.bmp" ;Unidad Logica, Ruta, Nombre y Extension del archivo de imagen a utilizar
handle dw ? ;DW=Define Word, para almacenar valores entre 0 y 65535, o sea 16 bits
col dw 0 ;COL=0
ren dw 479 ;REN=479d
; afueras db 0
buffer db ? ;DB=Define Byte, para almacenar valores entre 0 y 255, o sea 8 bits
colo db ? ; ? = Valor NO definido de inicio
; Cual herramienta se esta usando
tool db 1
; Datos para cuadro
col1 dw ?
ren1 dw ?
col2 dw ?
ren2 dw ?
; Macro para mostrar posicion de mouse
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
;**************************************************************************************************************************
.code
eti0:
    mov ah,3dh ;Funcion 3DH, abre un archivo existente
    mov al,0 ;AL=Modos de Acceso, 0=Solo Lectura, 1=Escritura, 2=Lectura/Escritura
    mov dx,offset filename ;DX=Direccion de la cadena de RUTA
    int 21h ;INT 21H función 3DH, abre un archivo. Esta funcion altera la bandera CF (Carry
    ;Flag), si el archivo se pudo abrir sin error CF=0, y en AX esta el Manejador de Archivo
    ;(Handle), caso contrario CF=1, y en AX esta el codigo de error
    jc err ;Si hay error, salta a la etiqueta ERR
    mov handle,ax ;Caso contrario HANDLE=Manejador de Archivo
;*************************************************************************************************************************
    mov cx,118d ;Se prepara ciclo de 118 vueltas (Para leer archivo en formato BMP)
eti1:
 push cx
 mov ah,3fh ;3FH=Leer del archivo
 mov bx,handle
 mov dx,offset buffer
 mov cx,1 ;CX=Numero de Bytes a leer
 int 21h ;INT 21H funcion 3FH, leer del archivo
 pop cx
 loop eti1
;*************************************************************************************************************************
 mov ah,00h ;Funcion 00H para la INT 10H (Resolucion de Pantalla)
 mov al,12h ;AL=Modo de despliegue o resolución, 12h = 640x480 a 16 colores
 int 10h ;INT 10H funcion 00H, inicializar resolucion
 ;***********************************************************************************************************************
eti2:
 mov ah,3fh ;3FH=Leer del archivo
 mov bx,handle
 mov dx,offset buffer
 mov cx,1
 int 21h ;INT 21H funcion 3FH, leer del archivo. En BUFFER se almacenaran los datos leidos

 mov al,buffer ;AL=BUFFER, en los 4 bits superiores esta el color de un PRIMER Pixel
 and al,11110000b
 ror al,4
 mov colo,al ;COLO=Color de un PRIMER Pixel
 mov ah,0ch ;Funcion 0CH para despliegue de un solo PIXEL con atributos
 mov al,colo ;AL=Atributos del Pixel
 mov cx,col ;CX=Columna de despliegue del Pixel
 mov dx,ren ;DX=Renglon de desplieguie del Pixel
 int 10h ;INT 10H funcion 0CH, pinta Pixel en coordenadas CX, DX

 mov al,buffer ;AL=BUFFER, en los 4 bits inferiores esta el color de un SEGUNDO Pixel
 and al,00001111b
 mov colo,al ;COLO=Color de un SEGUNDO Pixel
 inc col
 mov ah,0ch ;Funcion 0CH para despliegue de un solo PIXEL con atributos
 mov al,colo ;AL=Atributos del Pixel
 mov cx,col ;CX=Columna de despliegue del Pixel
 mov dx,ren ;DX=Renglon de desplieguie del Pixel
 int 10h ;INT 10H funcion 0CH, pinta Pixel en coordenadas CX, DX
 inc col ;Se debe desplegar otro Pixel para dar FORMATO a la imagen
 mov ah,0ch ;Funcion 0CH para despliegue de un solo PIXEL con atributos
 mov al,colo ;AL=Atributos del Pixel
 mov cx,col ;CX=Columna de despliegue del Pixel
 mov dx,ren ;DX=Renglon de desplieguie del Pixel
 int 10h ;INT 10H funcion 0CH, pinta Pixel en coordenadas CX, DX

 cmp col,639d
 jbe eti2 ;JBE=Jump if Below or Equal (salta si esta abajo o si es igual)

 mov col,0
 dec ren
 cmp ren,-1 ;Se compara con -1 para llegar hasta el ultimo renglon, que es el CERO
 jne eti2 ;JNE=Jump if Not Equal (salta si no es igual)
 mov colo,04h
 call curcolor
 
 jmp start ; jumps to drawing section
;***********************************************************************************************************************
err: ;Se llega hasta aqui solo si hay error en la lectura del archivo
 mov ah,09h
 lea dx,cad
 int 21h ;Despliega cad
 mov ah,07h
 int 21h ;Espera a que se oprima tecla
 int 20h ;Fin del Programa (Cuando NO se carga la imagen)
;  Macros
spraypix macro ren,col
 mov ah,0Ch ;Funcion 0Ch para pintar o desplegar PIXEL
 mov al,colo ;AL=Atributos de color, parte baja
 mov cx,ren ;Cx=Columna donde se despliega PIXEL
 mov dx,col ;Dx=Renglon donde se despliega PIXEL
 push cx
 int 10h ;INT 10H funcion 0CH, despliega PIXEL de color en posicion CX (Columna), DX (Renglon)
 add cx,2d
 int 10h
 add cx,2d
 int 10h
 add cx,2d
 int 10h
 pop cx
 sub dx,2d
 int 10h
 sub dx,2d
 int 10h
 sub dx,2d
 int 10h
 sub dx,2d
 int 10h
 sub dx,2d
 int 10h
 endm
ponpix macro co,re ;Macro que recibe dos parámetros, en C y en R
 mov ah,0Ch ;Funcion 12d=0Ch para pintar o desplegar PIXEL
 mov al,colo ;AL=Atributos de color, parte baja
 mov cx,co ;Cx=Columna donde se despliega PIXEL (empieza desde cero)
 mov dx,re ;Dx=Renglon donde se despliega PIXEL (empieza desde cero)
 int 10h ;INT 10H funcion 0CH, despliega PIXEL de color en posicion CX (Columna), DX (Renglon)
 endm
borpix macro ren, col
    mov ah,0Ch ;Funcion 12d=0Ch para pintar o desplegar PIXEL
    mov al,0fh ;AL=Atributos de color, parte baja : Blanco como el panel de fondo
    mov cx,ren ;Cx=Columna donde se despliega PIXEL (empieza desde cero)
    mov dx,col ;Dx=Renglon donde se despliega PIXEL (empieza desde cero)
    int 10h ;INT 10H funcion 0CH, despliega PIXEL de color en posicion CX (Columna), DX (Renglon)
    inc cx
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    inc cx
    int 10h
    endm
    
;Inicio del Programa Principal
start:
etip:
    call prende ;Llama al procedimiento para prender el raton
    ; Muestra posicion en X y Y
    ; Define en que posicion se mostrara
    mov col, cx
    mov ren, dx
    mov ah,02h
    mov dl, 0d
    mov dh, 0d
    int 10h
    ; Los escribe en pantalla con un espacio de separacion
    numero col
    mov ah,02h
    mov dl,' ' ;Mover a DL un espacio en blanco
    int 21h
    numero ren
eti10:
    mov ax,3d
    int 33h ;Detecta coordenadas y boton oprimido
    cmp bx,0d
    je etip ;Mientras NO se oprima ningun boton, se cicla
    cmp bx,1d
    jne eti10 ;El programa regresa a eti10 si no es boton izq
    
    ; Solo puede pintar en el cuadro blanco
    cmp cx,178d
    jb eticolor0 ;JB=Jump if Below (Brinca si esta abajo)
    cmp cx,625d
    ja eticolor0 ;JA=Jmp if Above (Brinca si esta arriba)
    cmp dx,408d
    ja eticolor0
    cmp dx,15d
    jb eticolor0
    jmp draw
eticolor0:
    cmp dx,441d
    jb eticolor1 ;JB=Jump if Below (Brinca si esta abajo)
    cmp dx,469d
    ja eticolor1 ;JA=Jmp if Above (Brinca si esta arriba)
    cmp cx,36d
    ja eticolor1
    cmp cx,8d
    jb eticolor1
    mov colo, 00h
    call curcolor 
    jmp etip

eticolor1:
    cmp dx,441d
    jb eticolor2 ;JB=Jump if Below (Brinca si esta abajo)
    cmp dx,469d
    ja eticolor2 ;JA=Jmp if Above (Brinca si esta arriba)
    cmp cx,66d
    ja eticolor2
    cmp cx,38d
    jb eticolor2
    mov colo, 04h
    call curcolor 
    jmp etip
eticolor2:
    cmp dx,441d
    jb eticolor3 ;JB=Jump if Below (Brinca si esta abajo)
    cmp dx,469d
    ja eticolor3 ;JA=Jmp if Above (Brinca si esta arriba)
    cmp cx,96d
    ja eticolor3
    cmp cx,68d
    jb eticolor3
    mov colo, 02h
    call curcolor 
    jmp etip
eticolor3:
    cmp dx,441d
    jb eticolor4 ;JB=Jump if Below (Brinca si esta abajo)
    cmp dx,469d
    ja eticolor4 ;JA=Jmp if Above (Brinca si esta arriba)
    cmp cx,126d
    ja eticolor4
    cmp cx,98d
    jb eticolor4
    mov colo, 06h
    call curcolor 
    jmp etip
eticolor4:
    cmp dx,441d
    jb eticolor5 ;JB=Jump if Below (Brinca si esta abajo)
    cmp dx,469d
    ja eticolor5 ;JA=Jmp if Above (Brinca si esta arriba)
    cmp cx,156d
    ja eticolor5
    cmp cx,128d
    jb eticolor5
    mov colo, 01h
    call curcolor 
    jmp etip
eticolor5:
    cmp dx,441d
    jb eticolor6 ;JB=Jump if Below (Brinca si esta abajo)
    cmp dx,469d
    ja eticolor6 ;JA=Jmp if Above (Brinca si esta arriba)
    cmp cx,186d
    ja eticolor6
    cmp cx,158d
    jb eticolor6
    mov colo, 05h
    call curcolor 
    jmp etip
eticolor6:
    cmp dx,441d
    jb eticolor7 ;JB=Jump if Below (Brinca si esta abajo)
    cmp dx,469d
    ja eticolor7 ;JA=Jmp if Above (Brinca si esta arriba)
    cmp cx,216d
    ja eticolor7
    cmp cx,188d
    jb eticolor7
    mov colo, 03h
    call curcolor 
    jmp etip
eticolor7:
    cmp dx,441d
    jb eticolor8 ;JB=Jump if Below (Brinca si esta abajo)
    cmp dx,469d
    ja eticolor8 ;JA=Jmp if Above (Brinca si esta arriba)
    cmp cx,246d
    ja eticolor8
    cmp cx,218d
    jb eticolor8
    mov colo, 08h
    call curcolor 
    jmp etip
eticolor8:
    cmp dx,441d
    jb eticolor9 ;JB=Jump if Below (Brinca si esta abajo)
    cmp dx,469d
    ja eticolor9 ;JA=Jmp if Above (Brinca si esta arriba)
    cmp cx,276d
    ja eticolor9
    cmp cx,248d
    jb eticolor9
    mov colo, 07h
    call curcolor 
    jmp etip
eticolor9:
    cmp dx,441d
    jb eticolor10 ;JB=Jump if Below (Brinca si esta abajo)
    cmp dx,469d
    ja eticolor10 ;JA=Jmp if Above (Brinca si esta arriba)
    cmp cx,306d
    ja eticolor10
    cmp cx,278d
    jb eticolor10
    mov colo, 0Ch
    call curcolor 
    jmp etip
eticolor10:
    cmp dx,441d
    jb eticolor11 ;JB=Jump if Below (Brinca si esta abajo)
    cmp dx,469d
    ja eticolor11 ;JA=Jmp if Above (Brinca si esta arriba)
    cmp cx,336d
    ja eticolor11
    cmp cx,308d
    jb eticolor11
    mov colo, 0ah
    call curcolor 
    jmp etip
eticolor11:
    cmp dx,441d
    jb eticolor12 ;JB=Jump if Below (Brinca si esta abajo)
    cmp dx,469d
    ja eticolor12 ;JA=Jmp if Above (Brinca si esta arriba)
    cmp cx,366d
    ja eticolor12
    cmp cx,338d
    jb eticolor12
    mov colo, 0eh
    call curcolor 
    jmp etip
eticolor12:
    cmp dx,441d
    jb eticolor13 ;JB=Jump if Below (Brinca si esta abajo)
    cmp dx,469d
    ja eticolor13 ;JA=Jmp if Above (Brinca si esta arriba)
    cmp cx,396d
    ja eticolor13
    cmp cx,368d
    jb eticolor13
    mov colo, 09h
    call curcolor 
    jmp etip
eticolor13:
    cmp dx,441d
    jb eticolor14 ;JB=Jump if Below (Brinca si esta abajo)
    cmp dx,469d
    ja eticolor14 ;JA=Jmp if Above (Brinca si esta arriba)
    cmp cx,426d
    ja eticolor14
    cmp cx,398d
    jb eticolor14
    mov colo, 0dh
    call curcolor 
    jmp etip
eticolor14:
    cmp dx,441d
    jb eticolor15 ;JB=Jump if Below (Brinca si esta abajo)
    cmp dx,469d
    ja eticolor15 ;JA=Jmp if Above (Brinca si esta arriba)
    cmp cx,456d
    ja eticolor15
    cmp cx,428d
    jb eticolor15
    mov colo, 0bh
    call curcolor 
    jmp etip
eticolor15:
    cmp dx,441d
    jb etiexitbut ;JB=Jump if Below (Brinca si esta abajo)
    cmp dx,469d
    ja etiexitbut ;JA=Jmp if Above (Brinca si esta arriba)
    cmp cx,486d
    ja etiexitbut
    cmp cx,458d
    jb etiexitbut
    mov colo, 0fh
    call curcolor 
    jmp etip
etiexitbut:
    cmp dx,428d
    jb etitool1 ;JB=Jump if Below (Brinca si esta abajo)
    cmp dx,470d
    ja etitool1 ;JA=Jmp if Above (Brinca si esta arriba)
    cmp cx,620d
    ja etitool1
    cmp cx,578d
    jb etitool1
    jmp fin
etitool1:
    cmp dx,77d
    jb etitool2 ;JB=Jump if Below (Brinca si esta abajo)
    cmp dx,125d
    ja etitool2 ;JA=Jmp if Above (Brinca si esta arriba)
    cmp cx,19d
    jb etitool2
    cmp cx,67d
    ja etitool2
    mov tool,1d
    jmp eti10
etitool2:
    cmp dx,77d
    jb etitool3 ;JB=Jump if Below (Brinca si esta abajo)
    cmp dx,125d
    ja etitool3 ;JA=Jmp if Above (Brinca si esta arriba)
    cmp cx,97d
    jb etitool3
    cmp cx,145d
    ja etitool3
    mov tool,2d
    jmp eti10
etitool3:
    cmp dx,143d
    jb etitool4 ;JB=Jump if Below (Brinca si esta abajo)
    cmp dx,192d
    ja etitool4 ;JA=Jmp if Above (Brinca si esta arriba)
    cmp cx,19d
    jb etitool4
    cmp cx,67d
    ja etitool4
    mov tool,3d
    jmp eti10
etitool4:
    cmp dx,141d
    jb etitool5 ;JB=Jump if Below (Brinca si esta abajo)
    cmp dx,189d
    ja etitool5 ;JA=Jmp if Above (Brinca si esta arriba)
    cmp cx,97d
    jb etitool5
    cmp cx,145d
    ja etitool5
    mov tool,4d
    jmp eti10
etitool5:
    cmp dx,208d
    jb eti10 ;JB=Jump if Below (Brinca si esta abajo)
    cmp dx,256d
    ja eti10 ;JA=Jmp if Above (Brinca si esta arriba)
    cmp cx,20d
    jb eti10
    cmp cx,68d
    ja eti10
    mov tool,5d
    jmp eti10
    
draw:
    cmp tool,1
    je drawpen
    cmp tool,2
    je draweraser
    cmp tool,3
    je drawsquare
    cmp tool,4
    je drawspray
    cmp tool,5
    je drawbrush
drawpen:
    mov col,cx ;Carga en COL el valor de la columna
    mov ren,dx ;Carga en REN el valor del renglon
    call apaga ;Llama al procedimiento APAGA para apagar el raton
    ponpix col,ren ;Llama a la macro PONPIX para desplegar PIXEL
    jmp etip ;Salta incondicionalmente a etip y se cicla para esperar a que se oprima un boton
drawbrush:
    mov col,cx ;Carga en COL el valor de la columna
    mov ren,dx ;Carga en REN el valor del renglon
    call apaga ;Llama al procedimiento APAGA para apagar el raton
    mov cx, 10d ; Define el tamaño del pincel
    call brush
    jmp etip ;Salta incondicionalmente a etip y se cicla para esperar a que se oprima un boton
draweraser:
    mov col,cx ;Carga en COL el valor de la columna
    mov ren,dx ;Carga en REN el valor del renglon
    call apaga ;Llama al procedimiento APAGA para apagar el raton
    borpix col,ren ;Llama a la macro borpix para desplegar PIXEL
    jmp etip ;Salta incondicionalmente a etip y se cicla para esperar a que se oprima un boton
drawspray:
    mov col,cx ;Carga en COL el valor de la columna
    mov ren,dx ;Carga en REN el valor del renglon
    call apaga ;Llama al procedimiento APAGA para apagar el raton
    spraypix col,ren ;Llama a la macro spraypix para desplegar PIXEL
    jmp etip ;Salta incondicionalmente a etip y se cicla para esperar a que se oprima un boton
drawsquare:
    call cuadro
    jmp etip
fin:
 call apaga ;Apaga raton
 call cierragraf ;Cierra graficos
 int 20h ;Termina el programa

;------------------ Inicia Zona de Procedimientos ----------------------
uptpos proc
    mov col,cx
    mov ren, dx
    ret
    uptpos endp
brush proc ; Size is defined by cx value at start of procedure
    brush0:
    push cx
    ponpix col, ren
    inc col
    pop cx
    loop brush0
    ret
    brush endp
curcolor proc ; Size is defined by cx value at start of procedure
    mov ren, 242d
    mov cl, 28d
    curcolor0:
        mov ch, 28d
        mov col, 105d
        curcolorloop1:
            push cx
            ponpix col, ren
            inc col
            pop cx
            dec ch
            jnz curcolorloop1
    dec ren
    dec cl
    jnz curcolor0
    ret
    curcolor endp
cuadro proc
    mov col1,cx
    mov ren1,dx
    cuad0:
    mov ax,3d
    int 33h
    cmp bx,2d
    jne cuad0 ;Este ciclo (cuad0) solo termina si se oprime el botón Derecho
    cmp cx,178d
    jb cuad0 ;JB=Jump if Below (Brinca si esta abajo)
    cmp cx,625d
    ja cuad0 ;JA=Jmp if Above (Brinca si esta arriba)
    cmp dx,408d
    ja cuad0
    cmp dx,15d
    jb cuad0
    ; Apagar mouse para poner pixeles debajo
    mov ax, 2d
    int 33h
    mov col2,cx
    mov ren2,dx
    mov cx,col1
    mov dx,ren1
    cuad1: ;Inicia proceso para dibujar linea superior horizontal
    mov ah,0ch
    mov al,colo
    int 10h ; Pone el primer pixel
    cmp cx, col2
    jae cuad1izq
    inc cx
    jmp cuad1val
    cuad1izq:
    dec cx
    cuad1val:
    cmp cx,col2
    jne cuad1 ;JBE=Jump if not Equal
    int 10h
    mov cx,col1
    mov dx,ren2
    cuad2: ;Inicia proceso para dibujar linea inferior horizontal
    mov ah,0ch
    mov al,colo
    int 10h
    cmp cx, col2
    jae cuad2izq
    inc cx
    jmp cuad2val
    cuad2izq:
    dec cx
    cuad2val:
    cmp cx,col2
    jne cuad2
    int 10h
    mov cx,col1
    mov dx,ren1
    cuad3: ;Inicia proceso para dibujar linea izquierda vertical
    mov ah,0ch
    mov al,colo
    int 10h
    cmp dx, ren2
    jae cuad3up
    inc dx
    jmp cuad3val
    cuad3up:
    dec dx
    cuad3val:
    cmp dx,ren2
    jne cuad3
    int 10h
    mov cx,col2
    mov dx,ren1
    cuad4: ;Inicia proceso para dibujar linea derecha vertical
    mov ah,0ch
    mov al,colo
    int 10h
    cmp dx, ren2
    jae cuad4up
    inc dx
    jmp cuad4val
    cuad4up:
    dec dx
    cuad4val:
    cmp dx,ren2
    jne cuad4
    int 10h
    mov ax,2d
    int 33h
    ret
    cuadro endp
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

