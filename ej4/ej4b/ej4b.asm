extern strcmp
global invocar_habilidad

; Completar las definiciones o borrarlas (en este ejercicio NO serán revisadas por el ABI enforcer)
DIRENTRY_NAME_OFFSET EQU 0
DIRENTRY_PTR_OFFSET EQU 16
DIRENTRY_SIZE EQU 24

FANTASTRUCO_DIR_OFFSET EQU 0
FANTASTRUCO_ENTRIES_OFFSET EQU 8
FANTASTRUCO_ARCHETYPE_OFFSET EQU 16
FANTASTRUCO_FACEUP_OFFSET EQU 24
FANTASTRUCO_SIZE EQU 32


section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text

; void invocar_habilidad(void* carta, char* habilidad);
invocar_habilidad:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; RDI = void*    card ; Vale asumir que card siempre es al menos un card_t*
	; RSI = char*    habilidad

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

	cmp r12,0
	je return

	xor rbx,rbx
	
for: 
	movzx r14, word [r12 + 8] ; r14 = __dir_entries
    cmp rbx, r14                                ; Comparar i (rbx) con entries (r14)
    jge recursion

	mov r14, qword[r12]
	mov r15, qword[r14 + rbx * 8] ;puntero dir[i]

	mov rdi, r15                   ; RDI = puntero a directory_entry_t
    add rdi, DIRENTRY_NAME_OFFSET  ; RDI = puntero a ability_name
	;mov rdi,[r15 + DIRENTRY_NAME_OFFSET] ;La diferencia es que estoy pasando la memoria a la que apunta el puntero, no el puntero en si
	mov rsi,r13

	call strcmp

	cmp ax,0
	jne sigIteracion

	mov rcx, qword[r15 +DIRENTRY_PTR_OFFSET]
	mov rdi,r12
	call rcx

	jmp return

sigIteracion:
	inc rbx
	jmp for
recursion:
	mov rdi, qword [r12 + 16]
	mov rsi,r13
	call invocar_habilidad
return:
	add rsp,8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

