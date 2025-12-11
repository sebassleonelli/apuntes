extern malloc

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - es_indice_ordenado
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - indice_a_inventario
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ITEM_NOMBRE EQU 0
ITEM_FUERZA EQU 20
ITEM_DURABILIDAD EQU 24
ITEM_SIZE EQU 28

;; La funcion debe verificar si una vista del inventario está correctamente 
;; ordenada de acuerdo a un criterio (comparador)

;; bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador);

;; Dónde:
;; - `inventario`: Un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice`: El arreglo de índices en el inventario que representa la vista.
;; - `tamanio`: El tamaño del inventario (y de la vista).
;; - `comparador`: La función de comparación que a utilizar para verificar el
;;   orden.
;; 
;; Tenga en consideración:
;; - `tamanio` es un valor de 16 bits. La parte alta del registro en dónde viene
;;   como parámetro podría tener basura.
;; - `comparador` es una dirección de memoria a la que se debe saltar (vía `jmp` o
;;   `call`) para comenzar la ejecución de la subrutina en cuestión.
;; - Los tamaños de los arrays `inventario` e `indice` son ambos `tamanio`.
;; - `false` es el valor `0` y `true` es todo valor distinto de `0`.
;; - Importa que los ítems estén ordenados según el comparador. No hay necesidad
;;   de verificar que el orden sea estable.

global es_indice_ordenado
es_indice_ordenado:
    ; Prólogo: Guardar registros NO VOLÁTILES si se usan (rbx, r12-r15). 
    ; Usaremos solo registros volátiles (r8, r9, r10, r11) aparte de los argumentos, 
    ; por lo que no necesitamos guardar nada.
    
    ; rdi = inventario_ptr -> 8 bytes / 4 word
    ; rsi = indice_ptr -> 8 bytes / 4 word
    ; rdx = tamanio -> 2 bytes / 1 word
    ; rcx = comparador_ptr -> 8 bytes / 4 word
    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    push r15

    mov r12, rdi    ; r12 = inventario (puntero a array de punteros a item_t)
    mov r13, rsi    ; r13 = indice (puntero a array de uint16_t)
    mov r14w, dx    ; r14w = tamanio (uint16_t, parte baja de rdx)
    mov r15, rcx    ; r15 = comparador (puntero a función)

    xor r8, r8      ; r8w = i = 0 (contador del loop)

.ciclo:
    ; Verificar si i >= tamanio - 1 (ya que comparamos hasta el penúltimo)
    mov ax, r14w
    dec ax          ; ax = tamanio - 1
    cmp r8w, ax
    jge .true       ; Si i >= tamanio - 1, el arreglo está ordenado

    ; Obtener idx1 = indice[i]
    movzx r9, word [r13 + r8*2]      ; r9w = indice[i] (uint16_t)

    ; Obtener idx2 = indice[i+1]
    movzx r10, word [r13 + r8*2 + 2] ; r10w = indice[i+1] (uint16_t)

    ; Obtener item1 = inventario[idx1]
    mov rdi, [r12 + r9*8]           ; rdi = inventario[idx1] (puntero a item_t)

    ; Obtener item2 = inventario[idx2]
    mov rsi, [r12 + r10*8]          ; rsi = inventario[idx2] (puntero a item_t)
 ; Ca
    ; Llamar a comparador(item1, item2)
    call r15                        ; comparador devuelve bool (0 = false, !=0 = true)

    ; Si comparador devolvió != 0, significa que NO está en orden (según la lógica del código original)
    cmp rax, 1
    jnz .false

    ; Incrementar i y continuar loop
    inc r8
    jmp .ciclo

.true:
    mov rax, 1      ; Retornar true
    jmp .end

.false:
    xor rax, rax    ; Retornar false

.end:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

;; Dado un inventario y una vista, crear un nuevo inventario que mantenga el
;; orden descrito por la misma.

;; La memoria a solicitar para el nuevo inventario debe poder ser liberada
;; utilizando `free(ptr)`.

;; item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio);

;; Donde:
;; - `inventario` un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice` es el arreglo de índices en el inventario que representa la vista
;;   que vamos a usar para reorganizar el inventario.
;; - `tamanio` es el tamaño del inventario.
;; 
;; Tenga en consideración:
;; - Tanto los elementos de `inventario` como los del resultado son punteros a
;;   `ítems`. Se pide *copiar* estos punteros, **no se deben crear ni clonar
;;   ítems**

global indice_a_inventario
indice_a_inventario:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; RDI = item_t**  inventario
	; RSI = uint16_t* indice
	; EDX = uint16_t  tamanio

    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    ; guardar parámetros en registros no volátiles
    mov     r12, rdi        ; inventario (item_t**)
    mov     r13, rsi        ; indice (uint16_t*)
    movzx   r14d, dx        ; tamanio limpio
    xor     r8d, r8d        ; i = 0

    ; reservar memoria para nuevo inventario
    mov     rdi, r14         ; cantidad de elementos
    shl     rdi, 3           ; *8 porque son punteros de 64 bits
    call    malloc
    test    rax, rax
    jz      .fin             ; si malloc falla, retorno NULL
    mov     r15, rax         ; puntero al nuevo inventario

.ciclo:
    cmp     r8d, r14d
    jae     .fin             ; fin del bucle

    ; cargar índice i
    movzx   r9, word [r13 + r8*2] ; indice[i]

    ; validar que el índice esté dentro del rango [0, tamanio-1]
    cmp     r9d, r14d
    jae     .error_out_of_bounds

    ; copiar puntero del inventario al nuevo arreglo
    mov     r10, [r12 + r9*8]     ; inventario[indice[i]]
    mov     [r15 + r8*8], r10

    inc     r8d
    jmp .ciclo

.fin:
    mov     rax, r15
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

.error_out_of_bounds:
    xor     rax, rax        ; retornar NULL si el índice es inválido
    jmp     .fin
    

;| Registro 64 bits | 32 bits | 16 bits | 8 bits |
;| ---------------- | ------- | ------- | ------ |
;| rax              | eax     | ax      | al     |
;| rbx              | ebx     | bx      | bl     |
;| rcx              | ecx     | cx      | cl     |
;| rdx              | edx     | dx      | dl     |
;| rsi              | esi     | si      | sil    |
;| rdi              | edi     | di      | dil    |
;| r8               | r8d     | r8w     | r8b    |
;| r9               | r9d     | r9w     | r9b    |
;| ...              | ...     | ...     | ...    |
;Si escribís en un registro de 32 bits (eax, r8d, etc.), la parte alta de los 64 bits se limpia automáticamente.
;En cambio, si escribís en ax, al, r8w, etc., solo cambiás esa parte y el resto queda intacto