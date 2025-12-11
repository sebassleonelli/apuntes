extern malloc

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
TUIT_MENSAJE_OFFSET EQU 0
TUIT_FAVORITOS_OFFSET EQU 140
TUIT_RETUITS_OFFSET EQU 142 ; 2 de padding
TUIT_ID_AUTOR_OFFSET EQU 144
TUIT_SIZE EQU 148 ;La estructura se alinea al mas grande, en este caso 4 ==> 148/4 = 0 de resto

PUBLICACION_NEXT_OFFSET EQU 0
PUBLICACION_VALUE_OFFSET EQU 8
PUBLICACION_SIZE EQU 16

FEED_FIRST_OFFSET EQU 0 
FEED_SIZE EQU 8

USUARIO_FEED_OFFSET EQU 0;
USUARIO_SEGUIDORES_OFFSET EQU 8
USUARIO_CANT_SEGUIDORES_OFFSET EQU 16; 
USUARIO_SEGUIDOS_OFFSET EQU 24 
USUARIO_CANT_SEGUIDOS_OFFSET EQU 32 
USUARIO_BLOQUEADOS_OFFSET EQU 40; 
USUARIO_CANT_BLOQUEADOS_OFFSET EQU 48 
USUARIO_ID_OFFSET EQU 52; 
USUARIO_SIZE EQU 56 


; tuit_t **trendingTopic(usuario_t *usuario, uint8_t (*esTuitSobresaliente)(tuit_t *));
global trendingTopic 

; --- tuit_t** trendingTopic(usuario_t* usuario, uint8_t (*esTuitSobresaliente)(tuit_t*)) ---
; Argumentos: rdi=usuario, rsi=esTuitSobresaliente (función)
trendingTopic:
    push rbp
    mov rbp, rsp
    ; Guardar registros callee-saved (rbx, r12-r15)
    push rbx
    push r12
    push r13
    push r14
    push r15
    
    ; Guardar argumentos originales
    mov r12, rdi  ; r12 = usuario
    mov r13, rsi  ; r13 = esTuitSobresaliente

    call contarTuitsSobresalientes

    mov ebx,eax ;cantidad de tuits sobresalientes del ususario

    cmp ebx,0
    je .returnNull

    imul rbx,8
    inc rbx
    mov rdi,rbx

    call malloc

    mov r14,rax ;puntero al arreglo de tuits
    cmp r14,0
    je .returnNull

    mov r10d, dword[r12 + USUARIO_ID_OFFSET] ;usuario -> id
    mov r9, [r12 + USUARIO_FEED_OFFSET]
    mov r11, [r9 + FEED_FIRST_OFFSET] ;actual = usuario->feed->first

    xor r8,r8 ;indice arreglo

.while:

    cmp r11,0
    je .returnArreglo

    mov r15, [r11 + PUBLICACION_VALUE_OFFSET] ;puntero al tuit

    cmp r15,0
    je .sigIteracion

    cmp dword[r15 + TUIT_ID_AUTOR_OFFSET],r10d
    jne .sigIteracion

    jmp .aplicarFuncion

.aplicarFuncion:
    mov rdi, r15
    call r13
    cmp al,1
    jne .sigIteracion

    mov [r14 + r8*8],r15
    inc r8

.sigIteracion:
    mov r11, [r11 + PUBLICACION_NEXT_OFFSET]
    jmp .while

.returnNull:
    mov rax,0
    jmp .fin_trending
.returnArreglo:

    mov qword[r14 + r8*8],0
    mov rax,r14 

.fin_trending:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret


; --- uint32_t contarTuitsSobresalientes(usuario_t* usuario, uint8_t (*esTuitSobresaliente)(tuit_t*)) ---
; Argumentos: rdi=usuario, rsi=esTuitSobresaliente (función)
contarTuitsSobresalientes:
    push rbp
    mov rbp, rsp
    ; Guardar registros callee-saved (rbx, r12-r15)
    push rbx
    push r12
    push r13
    push r14
    push r15 

    ; Inicialización de registros
    mov r12, rdi      ; r12 = usuario
    mov r13, rsi      ; r10 = esTuitSobresaliente (función)
    
    cmp r12,0
    je .return

    cmp qword[r12 + USUARIO_FEED_OFFSET], 0
    je .return

    mov r8, [r12 + USUARIO_FEED_OFFSET]
    cmp qword[r8 + FEED_FIRST_OFFSET],0
    je .return

    mov r14, r8 ;publicacion actual
    mov r15, [r12 + USUARIO_ID_OFFSET] ;id_usuario

    xor r10,r10 ;contador de tuits
.while:

    cmp r14,0
    je .returnContador

    mov rbx, [r14 + PUBLICACION_VALUE_OFFSET] ;puntero al tuit

    cmp rbx,0
    je .sigIteracion

    cmp dword[rbx + TUIT_ID_AUTOR_OFFSET],r15d
    jne .sigIteracion

    jmp .aplicarFuncion

.aplicarFuncion:
    mov rdi, rbx
    call r13
    cmp al,1
    jne .sigIteracion
    inc r10

.sigIteracion:
    mov r14, [r14 + PUBLICACION_NEXT_OFFSET]
    jmp .while

.returnContador:
    mov eax,r10d
    jmp .fin
.return:
    mov rax,0
.fin:       ; Devolver el contador (r14d se extiende a rax automáticamente)
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret