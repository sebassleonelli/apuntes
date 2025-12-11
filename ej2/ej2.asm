; ------------------------
; Offsets para los structs
; Plataforma: x86_64 (LP64)
; ------------------------
extern malloc
section .data
extern free
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

global  invertirRecorridoConDirecciones
invertirRecorridoConDirecciones:

    push rbp
    mov rbp,rsp
    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp,8

    mov r12,rdi ;puntero al recorrido
    mov r13,rsi ;longitud en 64 bits

    cmp r12,0
    je returnNull

    cmp qword[r12 + REC_ACCIONES_OFFSET],0
    je returnNull 

    mov rdi,REC_SIZE

    call malloc 

    mov r14,rax ;r14 tiene nuestro puntero de vuelta 

    mov qword[r14 + REC_CANT_ACCIONES_OFFSET],r13 ;vuelta->cant_acciones = len;

    mov rax,r13
    imul rax,rax,4
    mov rdi,rax

    call malloc

    mov r15,rax ;r15 tiene nuestro puntero al array de acciones invertidas

    xor rbx,rbx
    mov r12, [r12 + REC_ACCIONES_OFFSET]

for: 
    cmp r13,rbx
    je returnVuelta

   mov r10, r13             ; r10 = len 
   sub r10, rbx              ; r10 = len - i
   dec r10                  ; r10 = len - i - 1
   
   mov rax, r10
   imul rax, rax, 4         ; rax = j * 4 (offset de lectura)
   mov edi, dword [r12 + rax]; edi = rec->acciones[j]

   call invertirAccion      ; eax = invertirAccion(edi)
   
   mov rdx, rbx
   imul rdx, rdx, 4         ; rsi = i * 4 (offset de escritura)
   mov dword [r15 + rdx], eax 

    inc rbx
    jmp for

returnVuelta: 
    mov [r14 + REC_ACCIONES_OFFSET],r15
    mov rax,r14
    jmp fin
returnNull: 
    mov rax,0
    jmp fin

fin:
    add rsp,8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

invertirAccion: 
    push rbp
    mov rbp,rsp
    push r12
    push r13
    push r14
    push r15

    mov r12d,edi ;accion

    cmp r12d,0
    je return1

    cmp r12d,1
    je return0

    cmp r12d,2
    je return3

    cmp r12d,3
    je return2

return0: 
    mov eax,0
    jmp fin2

return1: 
    mov eax,1
    jmp fin2

return2: 
    mov eax,2
    jmp fin2

return3: 
    mov eax,3
    jmp fin2

fin2:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret