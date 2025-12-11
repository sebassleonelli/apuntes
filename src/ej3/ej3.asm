;########### SECCION DE DATOS
section .data
extern malloc
;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
USUARIO_ID_OFFSET EQU 0
USUARIO_NIVEL_OFFSET EQU 4
USUARIO_SIZE EQU 8

ID_SIZE EQU 2

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
;usuario_t **asignarNivelesParaNuevosUsuarios(uint32_t *ids, uint32_t cantidadDeIds, uint8_t (*deQueNivelEs)(uint32_t)) {
global asignarNivelesParaNuevosUsuarios 
    asignarNivelesParaNuevosUsuarios:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    push rbx
    push rcx
    sub rsp, 8
    
    mov r12, rdi ;uint32_t *ids
    mov r13, rsi ;uint32_t cantidadDeIds
    mov r14, rdx ;uint8_t (*deQueNivelEs)(uint32_t)
    
    cmp r13, 0 ;if (cantidadDeIds == 0) return NULL;
    je .retornar_null
    
    ; Asignar memoria para el array de punteros
    mov rdi, r13 ;cantidadDeIds
    shl rdi, 3 ;cantidadDeIds * sizeof(usuario_t*) = cantidadDeIds * 8
    call malloc
    mov r15, rax ;usuario_t **res = malloc(...)
    
    mov rbx, 0 ;int i = 0
    .for:
    cmp rbx, r13 ;i < cantidadDeIds
    jge .fin
    
    ; Calcular offset para ids[i]: i * 4 (uint32_t = 4 bytes)
    ;OJO: Tengo *ids que apunta al primer elemento de un array
    ;de enteros de 32 bits, entonces para calcular el offsets
    ;hago: i * 4 bytes (idx * tamaño elem)
    ;si tuviera **ids ahí sí sería i * 8 bytes (idx * tamaño puntero)
    mov rax, rbx ;copiar i
    shl rax, ID_SIZE ;i * 4
    mov edi, [r12 + rax] ;uint32_t id = ids[i] (cargar 32 bits)
    mov ecx, edi ;guardar id en ecx para después
    
    ; Llamar a deQueNivelEs(id)
    call r14 ;deQueNivelEs(id)
    ; Guardar el nivel en el stack antes de llamar a malloc
    ; (r8 es volátil y malloc puede modificarlo)
    push rax ;guardar el nivel (push guarda 64 bits, pero solo usamos el byte bajo)
    
    ; Asignar memoria para el nuevo usuario
    mov rdi, USUARIO_SIZE ;sizeof(usuario_t)
    call malloc ;usuario_t *new_u = malloc(sizeof(usuario_t))
    ; rax ahora contiene el puntero al nuevo usuario
    
    ; Recuperar el nivel del stack
    pop r8 ;recuperar el nivel (ahora en r8b)
    
    ; Asignar valores al usuario (ecx tiene el id, r8b tiene el nivel)
    mov dword [rax + USUARIO_ID_OFFSET], ecx ;new_u->id = id
    mov byte [rax + USUARIO_NIVEL_OFFSET], r8b ;new_u->nivel = n
    
    ; Calcular offset para res[i]: i * 8 (puntero = 8 bytes)
    mov rdx, rbx ;copiar i
    shl rdx, 3 ;i * 8
    mov [r15 + rdx], rax ;res[i] = new_u
    
    inc rbx
    jmp .for
    
    .fin:
    mov rax, r15 ;return res
    jmp .limpiar
    
    .retornar_null:
    xor rax, rax ;return NULL
    
    .limpiar:
    add rsp, 8
    pop rcx
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp 
    ret