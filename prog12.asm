;Programa 12.- Programa que carga o despliega una imagen BMP pixel por pixel en pantalla (640x480)
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
buffer db ? ;DB=Define Byte, para almacenar valores entre 0 y 255, o sea 8 bits
colo db ? ; ? = Valor NO definido de inicio
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
 mov al,12h ;AL=Modo de despliegue o resolución, 18 = 640x480 a 16 colores
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
 mov colo,03h
jmp start ; jumps to drawing section
 ;***********************************************************************************************************************
 mov ah,07h
 int 21h ;Espera que se oprima una tecla
 mov ah,00h ;Funcion 00H para devolver al modo TEXTO
 mov al,3d ;AL=Modo de despliegue o resolución, 3 = 80x25 a 16 colores (Modo TEXTO)
 int 10h ;INT 10H funcion 00H, inicializar resolucion
;  int 20h ;Fin del Programa (Cuando se carga la imagen)
;***********************************************************************************************************************
err: ;Se llega hasta aqui solo si hay error en la lectura del archivo
 mov ah,09h
 lea dx,cad
 int 21h ;Despliega cad
 mov ah,07h
 int 21h ;Espera a que se oprima tecla
 int 20h ;Fin del Programa (Cuando NO se carga la imagen)

 ponpix macro co,re ;Macro que recibe dos parámetros, en C y en R
 mov ah,0Ch ;Funcion 12d=0Ch para pintar o desplegar PIXEL
 mov al,colo ;AL=Atributos de color, parte baja: 1010b=10d=Color Verde (vea Paleta de Color)
;  mov cx,c ;Cx=Columna donde se despliega PIXEL (empieza desde cero)
;  mov dx,r ;Dx=Renglon donde se despliega PIXEL (empieza desde cero)
 int 10h ;INT 10H funcion 0CH, despliega PIXEL de color en posicion CX (Columna), DX (Renglon)
endm
;Inicio del Programa Principal
start:
; call inigraf ;Llama al procedimiento para iniciar graficos
etip:
call prende ;Llama al procedimiento para prender el raton
eti10:
    mov ax,3d
    int 33h ;Detecta coordenadas y boton oprimido
    cmp bx,0d
    je etip ;Mientras NO se oprima ningun boton, se cicla
    cmp bx,1d
    jne fin ;El programa termina si se oprime el boton derecho o los 2 botones
    
    ; Solo puede pintar en el cuadro blanco
    cmp cx,178d
    jb etip ;JB=Jump if Below (Brinca si esta abajo)
    cmp cx,625d
    ja etip ;JA=Jmp if Above (Brinca si esta arriba)
    cmp dx,408d
    ja etip
    cmp dx,15d
    jb etip

    mov col,cx ;Carga en COL el valor de la columna
    mov ren,dx ;Carga en REN el valor del renglon
    call apaga ;Llama al procedimiento APAGA para apagar el raton
    ponpix col,ren ;Llama a la macro PONPIX para desplegar PIXEL
    ; ponpix col,ren ;Llama a la macro PONPIX para desplegar PIXEL
    ; ponpix col+1,ren+1 ;Llama a la macro PONPIX para desplegar PIXEL
    ; ponpix col,ren+1 ;Llama a la macro PONPIX para desplegar PIXEL
    ; call prende ;Llama al procedimiento PRENDE para prender el raton
    jmp eti10 ;Salta incondicionalmente a ETI0 y se cicla para esperar a que se oprima un boton
    
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

