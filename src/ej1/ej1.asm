;########### SECCION DE DATOS
section .data
extern malloc
;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
USUARIO_ID_OFFSET EQU 0
USUARIO_NIVEL_OFFSET EQU 4
USUARIO_SIZE EQU 8

PRODUCTO_USUARIO_OFFSET EQU 0
PRODUCTO_CATEGORIA_OFFSET EQU 8
PRODUCTO_NOMBRE_OFFSET EQU 17
PRODUCTO_ESTADO_OFFSET EQU 42
PRODUCTO_PRECIO_OFFSET EQU 44
PRODUCTO_ID_OFFSET EQU 48
PRODUCTO_SIZE EQU 56

PUBLICACION_NEXT_OFFSET EQU 0
PUBLICACION_VALUE_OFFSET EQU 8
PUBLICACION_SIZE EQU 16

CATALOGO_FIRST_OFFSET EQU 0
CATALOGO_SIZE EQU 8
 
;PARA ABI CHEQUEAR REGISTROS VOLATILES,PILA LOS VOLATILES LOS LLENA DE BASURA AL HACER UNA LLAMADA

;producto_t* filtrarPublicacionesNuevasDeUsuariosVerificados (catalogo*)
global filtrarPublicacionesNuevasDeUsuariosVerificados
filtrarPublicacionesNuevasDeUsuariosVerificados:

    push rbp
    mov rbp,rsp
    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp, 8 ;agregamos solo a las funciones que llaman a otras funciones

    mov r12,rdi ;r12 contiene el catalogo

    mov rdi,[r12 + CATALOGO_FIRST_OFFSET] ;pasamos la primera publicacion a contador

    call contadorDePublicacionesValidas

    mov ebx,eax ;ebx contiene la cantidad de publicaciones

    inc rbx
    imul rbx,8
    mov rdi,rbx

    call malloc

    mov r14, rax ;puntero al array de productos

    mov r13,[r12 + CATALOGO_FIRST_OFFSET] ;puntero a publicacion actual

    xor r15,r15

while1: 
    cmp r13,0
    je returnArray

    mov r11, [r13 + PUBLICACION_VALUE_OFFSET] ;actual -> value
    mov rdi,r11
    call verificarProducto

    cmp eax,0
    je sigIteracion
    ;equivalente a sacar el sub rsp,8 y pushear y popear antes y despues de la llamada
    mov r11,[r13 + PUBLICACION_VALUE_OFFSET];el abi me llena de basura los volatiles, lo vuelvo a cargar
    mov [r14 + r15*8], r11 ;publicacionesValidas[i] = actual->value
    inc r15
    jmp sigIteracion

sigIteracion:
    mov r13,[r13 + PUBLICACION_NEXT_OFFSET]
    jmp while1

returnArray:

    mov qword[r14 + r15*8],0
    mov rax,r14
    jmp fin0 
fin0:
    add rsp, 8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

verificarProducto:
    ;rdi puntero a producto
    push rbp
    mov rbp,rsp
    push r12
    push r13
    push r14
    push r15
    push rbx

    mov r12,rdi ;r12 contiene el puntero al producto

    cmp r12, 0       
    je return0

    mov r13, qword[r12 + PRODUCTO_USUARIO_OFFSET] ;usuario_t* user = producto->usuario

    cmp r13, 0       
    je return0

    cmp word[r12 + PRODUCTO_ESTADO_OFFSET],1
    jne return0

    cmp byte[r13 + USUARIO_NIVEL_OFFSET],1
    jl return0

    mov eax,1
    jmp fin1

return0:
    mov eax,0
    jmp fin1

fin1:
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

contadorDePublicacionesValidas:
    ;rdi puntero a la primer publicacion
    push rbp
    mov rbp,rsp
    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp, 8

    mov r12,rdi ;r12 contiene el puntero a la primer publicacion

    xor r8d,r8d ;contador de publi

while0: 
    cmp r12,0
    je fin2

    mov rdi,[r12 + PUBLICACION_VALUE_OFFSET]
    call verificarProducto

    cmp eax,1
    jne itSig

    inc r8d
    jmp itSig

itSig:
    mov r12,[r12 + PUBLICACION_NEXT_OFFSET]
    jmp while0

fin2:
    mov eax,r8d
    add rsp, 8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

