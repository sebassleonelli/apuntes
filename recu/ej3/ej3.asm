; ------------------------
; Offsets para los structs
; Plataforma: x86_64 (LP64)
; ------------------------

section .data

section .text

; COMPLETAR las definiciones (serán revisadas por ABI enforcer):
; ------------------------
; Contenido
; ------------------------
CONT_NOMBRE_OFFSET      EQU 0      ; char nombre[64]
CONT_VALOR_OFFSET       EQU 64     ; uint32_t valor
CONT_COLOR_OFFSET       EQU 68      ; char color[32]
CONT_ES_TESORO_OFFSET   EQU 100     ; bool es_tesoro
CONT_PESO_OFFSET        EQU 104   ; float peso
CONT_SIZE               EQU 108      ; sizeof(Contenido) (rounded)

; ------------------------
; Habitacion
; ------------------------
HAB_ID_OFFSET          EQU 0         ; uint32_t id
HAB_VECINOS_OFFSET     EQU 4         ; uint32_t vecinos[ACC_CANT] (4 entradas)
HAB_CONTENIDO_OFFSET   EQU 20        ; Contenido contenido (aligned to 4)
HAB_VISITAS_OFFSET     EQU 128       ; uint32_t visitas
HAB_SIZE               EQU 132       ; sizeof(Habitacion)

; ------------------------
; Mapa
; ------------------------
MAP_HABITACIONES_OFFSET    EQU 0     ; Habitacion *habitaciones  (pointer, 8 bytes)
MAP_N_HABITACIONES_OFFSET  EQU 8     ; uint64_t n_habitaciones       (8 bytes)
MAP_ID_ENTRADA_OFFSET      EQU 16   ; uint32_t id_entrada         (4 bytes)
MAP_SIZE                   EQU 24   ; sizeof(Mapa) (padded to 8)

; ------------------------
; Recorrido
; ------------------------
REC_ACCIONES_OFFSET        EQU 0     ; Accion *acciones  (pointer, 8 bytes)
REC_CANT_ACCIONES_OFFSET   EQU 8     ; uint64_t cant_acciones (8 bytes)
REC_SIZE                  EQU 16    ; sizeof(Recorrido)


; Notar que el enum aparece como puntero, entonces no afecta los offsets

global  sumarTesoros
sumarTesoros

    push rbp
    mov rbp,rsp
    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp,8

    mov r12, rdi ;mapa
    mov r13, rsi ;id habitacion actual
    mov r14, rdx ;puntero al array de bools visitados

    cmp r12,0
    je return0

    cmp r13,99
    je return0

    cmp byte [r14 + r13], 1
    je return0 

    mov byte [r14 + r13], 1
    xor rbx,rbx ;suma = 0

    mov rsi, [r12 + MAP_HABITACIONES_OFFSET]
    mov rax, r13
    imul rax,rax,HAB_SIZE
    lea r10,[rsi + rax] ;r10 = puntero a mapa->habitaciones[actual]

    cmp byte [r10 + HAB_CONTENIDO_OFFSET + CONT_ES_TESORO_OFFSET], 1
    jne bucle_vecinos

    add ebx, dword[r10 + HAB_CONTENIDO_OFFSET + CONT_VALOR_OFFSET]

bucle_vecinos:

    xor r15,r15

for: 
    cmp r15,4
    jae fin  ;r15 >= 4

    mov rsi, [r12 + MAP_HABITACIONES_OFFSET]
    mov rax, r13
    imul rax, rax, HAB_SIZE
    lea r10, [rsi + rax]

    lea r11, [r10 + HAB_VECINOS_OFFSET]
    mov r8d, dword[r11 + r15*4] ;edi = idVecino

    mov rdi,r12
    mov rsi,r8
    mov rdx,r14

    call sumarTesoros

    add ebx,eax

    inc r15
    jmp for

return0: 
    xor ebx,ebx
fin:
    mov eax,ebx
    add rsp,8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
    
