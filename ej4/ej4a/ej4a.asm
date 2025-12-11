extern malloc
extern sleep
extern wakeup
extern create_dir_entry

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio
sleep_name: DB "sleep", 0
wakeup_name: DB "wakeup", 0

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - init_fantastruco_dir
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - summon_fantastruco
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
DIRENTRY_NAME_OFFSET EQU 0
DIRENTRY_PTR_OFFSET EQU 16
DIRENTRY_SIZE EQU 24

FANTASTRUCO_DIR_OFFSET EQU 0
FANTASTRUCO_ENTRIES_OFFSET EQU 8
FANTASTRUCO_ARCHETYPE_OFFSET EQU 16
FANTASTRUCO_FACEUP_OFFSET EQU 24
FANTASTRUCO_SIZE EQU 32

; void init_fantastruco_dir(fantastruco_t* card);
global init_fantastruco_dir
init_fantastruco_dir:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	;  RDI = fantastruco_t*     card

	push rbp
	mov rbp,rsp
	push r12
	push r13
	push r15
	sub rsp,8

	mov r12,rdi ;puntero a la carta a inicializar

	mov r13,8
	imul r13,2
	mov rdi,r13

	call malloc

	mov r15,rax ;puntero a __dir

	mov rdi,sleep_name
	mov rsi, sleep 

	call create_dir_entry
	
	mov qword[r15], rax ;__dir[0]

	mov rdi,wakeup_name
	mov rsi,wakeup 

	call create_dir_entry

	mov qword[r15 + 8],rax

	mov qword[r12 + FANTASTRUCO_DIR_OFFSET],r15
	mov dword[r12 + FANTASTRUCO_ENTRIES_OFFSET],2
	mov qword[r12 + FANTASTRUCO_ARCHETYPE_OFFSET],0
	mov byte[r12 + FANTASTRUCO_FACEUP_OFFSET], FALSE

	mov rax,r12
	add rsp,8
	pop r15
	pop r13
	pop r12
	pop rbp
	ret

	
; fantastruco_t* summon_fantastruco();
global summon_fantastruco
summon_fantastruco:
	push rbp
	mov rbp,rsp
	push r12
	push r13
	push r15
	sub rsp,8

	mov rdi,FANTASTRUCO_SIZE
	call malloc

	mov r12,rax ;puntero a la carta

	mov byte[r12 + FANTASTRUCO_FACEUP_OFFSET],1
	mov qword[r12 + FANTASTRUCO_ARCHETYPE_OFFSET],0
	mov dword[r12 + FANTASTRUCO_ENTRIES_OFFSET],2

	mov rdi,8
	shl rdi,1

	call malloc

	mov r15,rax ;puntero a __dir

	mov rdi,sleep_name
	mov rsi, sleep 

	call create_dir_entry
	
	mov qword[r15], rax ;__dir[0]

	mov rdi,wakeup_name
	mov rsi,wakeup 

	call create_dir_entry

	mov qword[r15 + 8],rax
	mov qword[r12 + FANTASTRUCO_DIR_OFFSET],r15

	mov rax,r12
	add rsp,8
	pop r15
	pop r13
	pop r12
	pop rbp
	ret	

		