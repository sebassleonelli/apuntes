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
CONT_NOMBRE_OFFSET      EQU 0        ; char nombre[64]
CONT_VALOR_OFFSET       EQU 64       ; uint32_t valor
CONT_COLOR_OFFSET       EQU 68       ; char color[32]
CONT_ES_TESORO_OFFSET   EQU 100     ; bool es_tesoro
CONT_PESO_OFFSET        EQU 104     ; float peso
CONT_SIZE               EQU 108      ; sizeof(Contenido) (rounded)

; ------------------------
; Habitacion
; ------------------------
HAB_ID_OFFSET          EQU 0         ; uint32_t id
HAB_VECINOS_OFFSET     EQU 4        ; uint32_t vecinos[ACC_CANT] (4 entradas)
HAB_CONTENIDO_OFFSET   EQU 20        ; Contenido contenido (aligned to 4)
HAB_VISITAS_OFFSET     EQU 128      ; uint32_t visitas
HAB_SIZE               EQU 132     ; sizeof(Habitacion)

; ------------------------
; Mapa
; ------------------------
MAP_HABITACIONES_OFFSET    EQU 0     ; Habitacion *habitaciones  (pointer, 8 bytes)
MAP_N_HABITACIONES_OFFSET  EQU 8     ; uint64_t n_habitaciones       (8 bytes)
MAP_ID_ENTRADA_OFFSET      EQU 16    ; uint32_t id_entrada         (4 bytes)
MAP_SIZE                   EQU 24   ; sizeof(Mapa) (padded to 8)

; ------------------------
; Recorrido
; ------------------------
REC_ACCIONES_OFFSET        EQU 0     ; Accion *acciones  (pointer, 8 bytes)
REC_CANT_ACCIONES_OFFSET   EQU 8     ; uint64_t cant_acciones (8 bytes)
REC_SIZE                  EQU 16     ; sizeof(Recorrido)

; Notar que el enum aparece como puntero, entonces no afecta los offsets

global  encontrarTesoroEnMapa
encontrarTesoroEnMapa:
    push rbp
    mov rbp,rsp
    push r12
    push r13
    push r14
    push r15
    push rbx

    mov r12, rdi ;puntero al mapa
    mov r13, rsi ;puntero al recorrido
    mov r14, rdx ;puntero a acciones ejecutadas

    cmp r12, 0
    je returnFalse

    cmp r13,0
    je returnFalse

    mov qword [r14],0 ;*acciones_ejecutadas = 0;

    mov r15d, dword[r12 + MAP_ID_ENTRADA_OFFSET];uint32_t idHabActual = mapa->id_entrada;

    mov r10, [r12 + MAP_HABITACIONES_OFFSET]
    mov rax,r15 
    imul rax, rax, HAB_SIZE 

    add r10,rax

    cmp byte [r10 + HAB_CONTENIDO_OFFSET + CONT_ES_TESORO_OFFSET],1
    je returnTrue

    xor r8,r8 ;i = 0
    mov r9, qword[r13 + REC_CANT_ACCIONES_OFFSET]  ;rec->cant_acciones
for: 
    cmp r8,r9
    jge returnFalse 

    mov rax, [r13 + REC_ACCIONES_OFFSET] ;proxAccion = rec->acciones
    mov ebx, dword[rax + r8*4]

    mov r10, [r12 + MAP_HABITACIONES_OFFSET]
    mov rax, r15
    imul rax, rax, HAB_SIZE
    add r10,rax
    mov eax, dword [r10 + HAB_VECINOS_OFFSET +  rbx*4] ;uint32_t idVecino = mapa->habitaciones[idHabActual].vecinos[proxAccion]

    cmp eax,99
    je returnFalse

    mov r15d, eax ;idHabActual = idVecino;
    inc qword[r14] ;*acciones_ejecutadas += 1

    mov r10, [r12 + MAP_HABITACIONES_OFFSET]
    mov rax, r15
    imul rax, rax, HAB_SIZE
    add r10,rax

    cmp byte [r10 + HAB_CONTENIDO_OFFSET + CONT_ES_TESORO_OFFSET], 1
    je returnTrue

    inc r8
    jmp for

returnFalse: 
    mov rax,0
    jmp fin


returnTrue:
    mov rax,1
    jmp fin

fin:
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret