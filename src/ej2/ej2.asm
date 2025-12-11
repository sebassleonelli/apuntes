;########### SECCION DE DATOS
section .data

extern strcmp
extern free
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

;catalogo* removerCopias(catalogo* h)
global removerCopias
removerCopias:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp, 8

    xor r12, r12 ;va a ser mi actual, para recorrer el catalogo.
    xor r13, r13 ;r13 lo voy a usar para el anterior, arranca en null.
    xor r14, r14 ;lo voy a usar para comparar en la segunda iteración
    xor r15, r15 ;lo voy a usar para setear el producto
    xor rbx, rbx ;lo voy a usar para preservar el pr y el next antes de liberar memoria
    xor rsi, rsi ;lo voy a usar para el nombre del producto actual: pa -> nombre
    mov [rsp + 8], rdi 

    mov r12, [rdi + CATALOGO_FIRST_OFFSET]; actual = h->first
    mov r14, [rdi + CATALOGO_FIRST_OFFSET]; revision = h->first
    cmp r12, 0 ;si es 0, no hago nada, quiere decir que el catalogo está vacío
    je .fin

    .while:
    mov rdi, [rsp + 8]
    mov r14, [rdi + CATALOGO_FIRST_OFFSET]; revision = h->first
    mov r15, [r12 + PUBLICACION_VALUE_OFFSET] ; actual -> value Puntero al producto actual (pa)

    .cmp_loop:
    ;si revision es null entonces paso a la siguiente publicacion
    ;si revision no es null, reviso el siguiente producto
    cmp r14, 0
    je .check
    mov rbx, [r14 + PUBLICACION_VALUE_OFFSET] ;Producto a revisar (pr) 
    mov r8, rbx
    add r8, PRODUCTO_NOMBRE_OFFSET
    mov rcx, r8 ; pr -> nombre (no es un puntero, es un char[25])
    mov r8, r15 ;Necesito calcular a mano el puntero rbx+PRODUCTO_NOMBRE_OFFSET
    add r8, PRODUCTO_NOMBRE_OFFSET
    mov rsi, r8 ;pa -> nombre

    .if : 
    cmp rbx, r15 ;(pa == pr) si es el mismo puntero, sigo
    je .continue
    jne .or ;si no se trata del mismo puntero, reviso el resto

    .or:
    mov rdi, rcx ;en rdi pongo el nombre a revisar, como el nombre no es un puntero, simplemente lo cargo con mov
    mov rsi, rsi ;en rsi pongo el nombre actual
    call strcmp ;comparo los nombres
    cmp rax, 0 ;en rax está el resultado de strcmp
    je .or2 ;si (strcmp == 0) -> reviso los ids (&&)
    jne .continue ;si strcmp es != 0 paso al siguiente

    .or2:
    xor r8, r8
    xor r9, r9
    mov r9, [rbx + PRODUCTO_USUARIO_OFFSET] ;pr->usuario
    mov r9w, [r9 + USUARIO_ID_OFFSET] ;usuario->id
    mov r8, [r15 + PRODUCTO_USUARIO_OFFSET] ;pa -> usuario
    mov r8w, [r8 + USUARIO_ID_OFFSET] ;usuario->id
    cmp r8w, r9w
    je .check_cmp
    jne .continue

    .continue:
    mov r13, r14 ;anterior = revision
    mov r14, [r14 + PUBLICACION_NEXT_OFFSET] ;revision = revision->next
    jmp .cmp_loop

    .check_cmp:
    mov rdi, rbx ;free(pr) libero el producto
    call free
    ;necesito preservar next, porque tiene que sobrevivir al free
    ;guardo next en rbx
    mov rbx, [r14 + PUBLICACION_NEXT_OFFSET]; publicacion_t *next
    mov [r13 + PUBLICACION_NEXT_OFFSET], rbx ;anterior -> next = next
    mov rdi, r14 ;seteo el parametro a liberar (revision)
    call free ;free(revision)
    mov r14, rbx ;revision = next
    jmp .cmp_loop

    .check:
    mov r13, r12 ;anterior = actual
    mov r12, [r12 + PUBLICACION_NEXT_OFFSET] ;actual = actual -> next
    cmp r12, 0
    je .fin
    jne .while

    .fin:
    mov rax, [rsp + 8]
    add rsp, 8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret