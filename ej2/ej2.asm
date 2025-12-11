extern free

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
TUIT_MENSAJE_OFFSET EQU 0
TUIT_FAVORITOS_OFFSET EQU 140
TUIT_RETUITS_OFFSET EQU 142 
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

section .text
global bloquearUsuario
global borrarFeed

bloquearUsuario:
    ;rdi contiene el usuario
    ;rsi contiene el usuario a bloquear

    push rbp
    mov rbp,rsp
    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp,8

    mov r12,rdi
    mov r13,rsi 

    mov r14, [r12 + USUARIO_BLOQUEADOS_OFFSET] ;puntero al array de bloqueados
    mov ebx, dword[r12 + USUARIO_CANT_BLOQUEADOS_OFFSET]

    mov [r14 + rbx*8], r13 ;usuario->bloqueados[usuario->cantBloqueados] = usuario a bloquear

    inc ebx
    mov [r12 + USUARIO_CANT_BLOQUEADOS_OFFSET], ebx

    mov rdi ,[r12 + USUARIO_FEED_OFFSET]
    mov rsi, [r13 + USUARIO_ID_OFFSET]

    call limpiarFeed

    mov rdi,[r13 + USUARIO_FEED_OFFSET]
    mov rsi, [r12 + USUARIO_ID_OFFSET]

    call limpiarFeed

.fin:
    add rsp,8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

limpiarFeed:
    ;rdi recibe feed con las publicaciones 
    ;rsi recibe el id a borrar del feed

    push rbp
    mov rbp,rsp
    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp,8

    mov r12,rdi ;puntero a feed
    mov r13d,esi ;id_autor a borrar

    lea r14, [r12 + FEED_FIRST_OFFSET] ;Guarda la direccion de memoria al primer nodo

.while:

    mov rbx, [r14]  ;puntero a la publicacion actual
    cmp rbx,0
    je .end ;Debo hacer la comparacion de si el primero es null para salir del ciclo
                            
    mov r8, [rbx + PUBLICACION_VALUE_OFFSET] ;r8 contiene el puntero al tweet

    cmp dword[r8 + TUIT_ID_AUTOR_OFFSET],r13d 
    je .borrarPubli

    lea r14,[rbx + PUBLICACION_NEXT_OFFSET]
    jmp .while

.borrarPubli:

    mov r15,[rbx + PUBLICACION_NEXT_OFFSET] ;r15 es el siguiente nodo

    mov [r14],r15  ;Si R14 apuntaba a feed->first, actualizamos el inicio de la lista.
                   ;Si R14 apuntaba a anterior->next, actualizamos el anterior.
    mov rdi,rbx
    call free    

    jmp .while ;recordemos que r14 contiene el siguiente nodo, no avanzamos

.end:
    add rsp, 8          ; Restaurar alineación
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret