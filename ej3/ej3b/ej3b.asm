extern strcmp
section .rodata
	CLT: db "CLT", 0
	RBO: db "RBO", 0

;########### SECCION DE DATOS
section .data

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

CERRADO_FAVORABLE EQU 1
CERRADO_DESFAVORABLE EQU 2
global resolver_automaticamente

;void resolver_automaticamente(funcionCierraCasos* funcion, caso_t* arreglo_casos, caso_t* casos_a_revisar, int largo)
; rdi -> func* del tipo uint16_t (*)(caso_t* caso);
; rsi -> caso_t* arreglo de casos
; rdx -> caso_t* casos a revisar (agregar, tam suficiente)
; ecx -> largo 
resolver_automaticamente:
	push rbp
	mov rbp, rsp
	sub rsp, 8
	push rbx
	push r12
	push r13
	push r14
	push r15

	test ecx, ecx
	jz .fin
	; se puede asumir que tiene al menos un caso.
	;
	;
	mov rbx, rsi ; caso_t* de entrada.
	mov r12d, ecx ; largo del caso_t* entrada.

	mov r15, rdx ; caso_t* de salida a revisar.
	xor r13, r13 ; indice para r15.

	mov r14, rdi ; uint16_t funCierraCasos(caso_t*)


	.loop:
	mov rdi, rbx ; caso_t* actual.
	call r14

    ; cargo usuario_t* en rsi.
	mov rsi, QWORD [rbx + CASO_USUARIO_OFFSET]
	cmp DWORD [rsi + USUARIO_NIVEL_OFFSET], 0
	je .caso_sin_accion

	test ax, ax
	jz .check_clt_rbo	
	;
	; aca es caso favorable, ax=1
	;
	mov ax, CERRADO_FAVORABLE

	jmp .modificar_estado
	
	.caso_desfavorable:
	mov ax, CERRADO_DESFAVORABLE
	jmp .modificar_estado

	.check_clt_rbo: ; ax=0
	lea rdi, [rbx + CASO_CATEGORIA_OFFSET]
	lea rsi, [rel CLT]
	call strcmp
	test rax, rax
	jz .caso_desfavorable
	
	lea rdi, [rbx + CASO_CATEGORIA_OFFSET]
	lea rsi, [rel RBO]
	call strcmp
	test rax, rax
	jz .caso_desfavorable

	.caso_sin_accion:
	imul r8, r13, CASO_SIZE
	mov QWORD [r15 + r8], rbx
	inc r13
	jmp .continuarloop
.modificar_estado:
	; estado cargado en AX
	; en rbx el puntero apuntando a caso_t actual.
	mov WORD [rbx + CASO_ESTADO_OFFSET], AX

	.continuarloop:
	add rbx, CASO_SIZE
	dec r12d
	test r12d, r12d
	jnz .loop

	
	.fin:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	add rsp, 8
	pop rbp
    ret