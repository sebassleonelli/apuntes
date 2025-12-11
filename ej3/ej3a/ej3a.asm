;########### SECCION DE DATOS
section .data
extern malloc
;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
USUARIO_ID_OFFSET EQU 0
USUARIO_NIVEL_OFFSET EQU 4
USUARIO_SIZE EQU 8

CASO_CATEGORIA_OFFSET EQU 0
CASO_ESTADO_OFFSET EQU 4
CASO_USUARIO_OFFSET EQU 8
CASO_SIZE EQU 16

SEGMENTACION_CASOS0_OFFSET EQU 0
SEGMENTACION_CASOS1_OFFSET EQU 8
SEGMENTACION_CASOS2_OFFSET EQU 16
SEGMENTACION_SIZE EQU 24

ESTADISTICAS_CLT_OFFSET EQU 0
ESTADISTICAS_RBO_OFFSET EQU 1
ESTADISTICAS_KSC_OFFSET EQU 2
ESTADISTICAS_KDT_OFFSET EQU 3
ESTADISTICAS_ESTADO0_OFFSET EQU 4
ESTADISTICAS_ESTADO1_OFFSET EQU 5
ESTADISTICAS_ESTADO2_OFFSET EQU 6
ESTADISTICAS_SIZE EQU 7

;segmentacion_t* segmentar_casos(caso_t* arreglo_casos, int largo)
global segmentar_casos
segmentar_casos:
    ;RDI = ARREGLO_CASOS (puntero a inicio del array)
    ;RSI = LARGO
    ;DEBEMOS DEVOLVER EN RAX UN PUNTERO A LA SEGMENTACION

    push rbp
    mov rbp,rsp
    push r12
    push r13
    push rbx
    sub rsp,8
    mov r12,rdi ;r12 contiene el puntero al arreglo de casos
    mov r13,rsi ;Controlar que int son 4 bytes

    mov rdi,SEGMENTACION_SIZE

    call malloc

    mov rbx,rax ;rbx contiene el puntero al malloc de retorno

    cmp r12,0
    je .devolverNull

    mov rdi,r12 ;puntero para pasar como argumento
    mov rsi,r13 ;largo para parametro
    mov rcx,0 ; nivel a contar

    call contar_casos_por_nivel

    mov r14,rax ;cantidadCasos0 CHEQUEAR EL TAMANIO DE REGISTRO

    cmp r14,0
    je .casos_nivel0_null

    imul r14,CASO_SIZE 
    mov rdi,r14

    call malloc

    mov r15,rax ;puntero a casos_nivel0

    mov [rbx + SEGMENTACION_CASOS0_OFFSET], r15

    mov rdi,r12 ;puntero para pasar como argumento
    mov rsi,r13 ;largo para parametro
    mov rcx,1 ; nivel a contar

    call contar_casos_por_nivel

    mov r14,rax ;cantidadCasos1 CHEQUEAR EL TAMANIO DE REGISTRO

    cmp r14,0
    je .casos_nivel1_null

    imul r14,CASO_SIZE 
    mov rdi,r14

    call malloc

    mov r15,rax ;puntero a casos_nivel1

    mov [rbx + SEGMENTACION_CASOS1_OFFSET], r15

    mov rdi,r12 ;puntero para pasar como argumento
    mov rsi,r13 ;largo para parametro
    mov rcx,2 ; nivel a contar

    call contar_casos_por_nivel

    mov r14,rax ;cantidadCasos2 CHEQUEAR EL TAMANIO DE REGISTRO

    cmp r14,0
    je .casos_nivel2_null

    imul r14,CASO_SIZE 
    mov rdi,r14

    call malloc

    mov r15,rax ;puntero a casos_nivel2

    mov [rbx + SEGMENTACION_CASOS2_OFFSET], r15

    xor r8,r8 ;i=0
    xor r9,r9 ;indA = 0
    xor r10,r10;indB = 0
    xor r11,r11;indC = 0

.for:
    cmp r8d,r13d
    jge .fin

    mov r15,r8
    imul r15,CASO_SIZE
    add r15 ,r12 ;arreglo_casos[i]

    mov rax,[r15 + CASO_USUARIO_OFFSET];arreglo_casos[i].usuario;
    mov r15, [rax + USUARIO_NIVEL_OFFSET]

    cmp r15,0
    je .casos_nivel0

    cmp r15,1
    je .casos_nivel1

    cmp r15,2
    je .casos_nivel2

    inc r8
    jmp .for

.casos_nivel0:
    ; casos_nivel0[indA] = arreglo_casos[i]
    mov rax, [rbx + SEGMENTACION_CASOS0_OFFSET]   ; rax = puntero a casos_nivel0

    mov rdx, r9                                    ; rdx = indA
    imul rdx, CASO_SIZE                            ; offset dentro del array

    add rax, rdx                                    ; puntero destino

    ; Copiamos el caso completo (estructura caso_t)
    mov rcx, CASO_SIZE
    mov rsi, r12
    mov rdi, rax

    ; r15 = index original (i * CASO_SIZE)
    ; OJO: YA LO TENÉS CALCULADO, USALO:
    ; rsi = arreglo_casos + (i * CASO_SIZE)
    mov rsi, r12
    mov rdx, r8
    imul rdx, CASO_SIZE
    add rsi, rdx

    ; copia de CASO_SIZE bytes
.copy_caso0:
    mov bl, [rsi]
    mov [rdi], bl
    inc rsi
    inc rdi
    loop .copy_caso0

    inc r9          ; indA++
    inc r8          ; i++
    jmp .for

.casos_nivel1:
    mov rax, [rbx + SEGMENTACION_CASOS1_OFFSET]
    mov rdx, r10
    imul rdx, CASO_SIZE
    add rax, rdx
    mov rcx, CASO_SIZE
    mov rsi, r12
    mov rdx, r8
    imul rdx, CASO_SIZE
    add rsi, rdx
.copy_caso1:
    mov bl, [rsi]
    mov [rax], bl
    inc rsi
    inc rax
    loop .copy_caso1
    inc r10
    inc r8
    jmp .for

.casos_nivel2:
    mov rax, [rbx + SEGMENTACION_CASOS2_OFFSET]
    mov rdx, r11
    imul rdx, CASO_SIZE
    add rax, rdx
    mov rcx, CASO_SIZE
    mov rsi, r12
    mov rdx, r8
    imul rdx, CASO_SIZE
    add rsi, rdx
.copy_caso2:
    mov bl, [rsi]
    mov [rax], bl
    inc rsi
    inc rax
    loop .copy_caso2
    inc r11
    inc r8
    jmp .for

.devolverNull:
    ; si arreglo == NULL, devolver struct con punteros NULL
    mov qword [rbx + SEGMENTACION_CASOS0_OFFSET], 0
    mov qword [rbx + SEGMENTACION_CASOS1_OFFSET], 0
    mov qword [rbx + SEGMENTACION_CASOS2_OFFSET], 0
    mov rax, rbx
    jmp .fin
    
.casos_nivel0_null:
    mov qword [rbx + SEGMENTACION_CASOS0_OFFSET], 0
.casos_nivel1_null:
    mov qword [rbx + SEGMENTACION_CASOS1_OFFSET], 0
.casos_nivel2_null:
    mov qword [rbx + SEGMENTACION_CASOS2_OFFSET], 0
.fin:
    mov rax, rbx    ; devolver struct
    add rsp,8
    pop rbx
    pop r13
    pop r12
    pop rbp
    ret

   
contar_casos_por_nivel:
    ;RDI contiene un puntero al array de casos
    ;RSI contiene el largo del array
    ;RBX contiene el nivel a comparar
 