extern malloc
extern strcmp

extern free

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
;   - optimizar
global EJERCICIO_2A_HECHO
EJERCICIO_2A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contarCombustibleAsignado
global EJERCICIO_2B_HECHO
EJERCICIO_2B_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1C como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - modificarUnidad
global EJERCICIO_2C_HECHO
EJERCICIO_2C_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ATTACKUNIT_CLASE EQU 0
ATTACKUNIT_COMBUSTIBLE EQU 12
ATTACKUNIT_REFERENCES EQU 14
ATTACKUNIT_SIZE EQU 16

MAP_SIZE EQU 255

global optimizar
optimizar:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; RDI = mapa_t           mapa
	; RSI = attackunit_t*    compartida
	; RDX = uint32_t*        fun_hash(attackunit_t*)

	push rbp
	mov rbp,rsp
	push r12
	push r13
	push r14 
	push rbx
	sub rsp,8

	mov r12, rdi ;Puntero base al mapa
	mov r13, rsi ; puntero a la unidad compartida
	mov r14, rdx ;puntero a funcion de hash

	mov rdi,r13
	call r14
	mov ebx,eax ;int de retorno de la funcion de hash para la unidad compartida

	mov byte[r13 + ATTACKUNIT_REFERENCES], 0 ;	compartida->references = 0;

	xor r8,r8 ;i = 0

.cicloI: 
	cmp r8d,255
	jge .fin
	
	xor r9,r9

.cicloJ:

	cmp r9d,255
	jge  .inc_i

	mov     r10, r8
    imul    r10, 2040; 255 * 8 = 2040 bytes por fila
    add     r10, r12 ; r10 = &mapa[i][0]
    ; mapa[i][j]
    mov     r11, [r10 + r9*8]

	cmp r11,0
	je .inc_j

	cmp r11,r13
	je .continue

	mov rdi,r11

	call r14

	cmp eax,ebx
	jne .inc_j
    ; compartida->references++
	movzx ax, [r13 + ATTACKUNIT_REFERENCES]
	inc ax
	mov [r13 + ATTACKUNIT_REFERENCES], ax
	; mapa[i][j] = compartida
	mov [r10 + r9*8],r13

	jmp .inc_j

.inc_i:
	inc r8
	jmp .cicloI


.continue:
	
	movzx ax, [r13 + ATTACKUNIT_REFERENCES]
	inc ax
	mov [r13 + ATTACKUNIT_REFERENCES], ax
	jmp .inc_j

.inc_j:
    inc r9
    jmp .cicloJ

.fin:
	add rsp,8
	pop rbx
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

global contarCombustibleAsignado
contarCombustibleAsignado:
	; RDI = mapa_t           mapa
	; RSI = uint16_t*        fun_combustible(char*)

	push rbp
	mov rbp,rsp
	push r12
	push r13
	push r14 
	push r15
	push rbx
	sub rsp,8

	mov r12, rdi ;Puntero base al mapa
	mov r13, rsi ; puntero a la funcion de combustible

	xor r15d,r15d ; reservas = 0
	xor r8d,r8d ;i = 0

.cicloI: 
	cmp r8d,255
	jge .fin
	
	xor r9,r9 ; j=0

.cicloJ:

	cmp r9d,255
	jge  .inc_i

	mov     r10, r8
    imul    r10, 2040; 255 * 8 = 2040 bytes por fila
    add     r10, r12 ; r10 = &mapa[i][0]
    ; mapa[i][j]
    mov     r11, [r10 + r9*8]

	cmp r11,0  ;Actual == 0
	je .inc_j
	
	lea rdi,[r11 + ATTACKUNIT_CLASE]

	call r13

	movzx r14d, ax        ; comBase = uint16_t
    ; cargar actual->combustible
    movzx ebx, word [r11 + ATTACKUNIT_COMBUSTIBLE]
    ; diferencia = combust - comBase  (uint16)
    sub ebx, r14d
    ; reserva += diferencia
	add r15d,ebx

.inc_j:
    inc r9
    jmp .cicloJ

.inc_i:
	inc r8
	jmp .cicloI

.fin:
	mov eax,r15d
	add rsp,8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

global modificarUnidad
modificarUnidad:
	; rdi = mapa_t           mapa
	; rsi  = uint8_t          x
	; rdx  = uint8_t          y
	; rcx = void*            fun_modificar(attackunit_t*)

	; mapa + (255*x+y)*8

	; Aclaraciones y detalles de este ejercicio a tener en cuenta:
	; - Se puede asumir que el char* clase está terminado en 0.
	; - x es la fila e y es la columna (puede generar confusión)
	;       => se utilizan así para indexar: mapa[x][y]
	;       => ¿Cuál es el offset de esa posición en el mapa? (RTA: (x*255 + y))
	; - El tamaño del mapa es 255x255 (no 256x256). 256 es potencia de 2 (2**8 = 256) pero 255 no. 
	;   Sin embargo para hacer x*255 podemos hacer x*256 - x.
	;   Lo implementamos como shift_left(x, 8) - x.
	;   Esto es más eficiente que hacer un mul/imul.

	; mapa + (x*255 + y)*8

	push rbp
	mov rbp, rsp

	push r12
	push r13
	push r14 
	push r15
	push rbx
	sub rsp, 8 ; para alinear pila

	;limpio x e y
	xor r13, r13
	mov r13b, sil ; x ;rsi 8 bits = sil
	
	xor r14, r14
	mov r14b, dl ; y  ;rdx 8 bits = dl
	
	shl r13, 8   ; x*256
	sub r13, rsi ; x*256-x = x*255
	add r13, r14 ; x+y

	mov r12, rdi; mapa
	mov r15, rcx; fun_modificar

	mov rax, [r12 + r13*8] ; puntero a unidad a modificar 
	;attackunit_t* to_modify está en rax

	cmp rax, 0
	je .fin

.revisarCantidadReferencias:
	mov dil, byte[rax + ATTACKUNIT_REFERENCES]
	cmp dil, 1 ; Si hay más de una posición utilizando esta unidad (se optimizó), necesito aplicar la modificación en una nueva instancia
	           ; si no, se modificarían todas las instancias simultáneamente
			   ; Entonces: 
			   ; - Si referencias = 1, modifico la instancia directo. 
			   ; - Si referencias > 1, creo una copia de la instancia y modifico la nueva copia (que solo será referencia por la posición actual).
	; Queda en rax el puntero de la unidad a modificar
	je .modificarUnidad
	
	.crearNuevaInstancia:
	; Pido memoria para hacer una copia de la unidad que queremos modificar
	mov rdi, ATTACKUNIT_SIZE
	call malloc
	;rax = puntero a nueva unidad (que sí se podrá modificar)
	
	.copiarUnidad:
	mov rcx, [r12 + r13*8] ; calculo otra vez actual pq malloc lo borra

	mov r8, [rcx + ATTACKUNIT_CLASE]       ;Copio los primeros 8 bytes de clase
	mov [rax + ATTACKUNIT_CLASE ], r8
	mov r8d, [rcx + ATTACKUNIT_CLASE + 8]  ;Copio los últimos 3 bytes de clase (8+3=11) y un byte de padding
	mov [rax + ATTACKUNIT_CLASE + 8], r8d

	mov r8w, [rcx + ATTACKUNIT_COMBUSTIBLE]
	mov [rax + ATTACKUNIT_COMBUSTIBLE], r8w

	; No copio la cantidad de referencias, directamente la pongo en 1
	mov [rax + ATTACKUNIT_REFERENCES], byte 1

	.reemplazarUnidad:
	mov [r12 + r13*8], rax ; Piso en la matriz con el puntero a la nueva unidad

	.disminuirReferenciasUnidadOriginal:
	mov r8b, byte[rcx + ATTACKUNIT_REFERENCES]
	dec r8b
	mov byte[rcx + ATTACKUNIT_REFERENCES], r8b 

	.modificarUnidad:
	; Se espera que en rax llegue el puntero a la unidad a modificar
	mov rdi, rax ; le paso actual como parametro a fun_modificar
	call r15

	.fin:

	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	
	pop rbp


	ret