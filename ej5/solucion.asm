; Definiciones comunes
TRUE  EQU 1
FALSE EQU 0

; Identificador del jugador rojo
JUGADOR_ROJO EQU 1
; Identificador del jugador azul
JUGADOR_AZUL EQU 2

; Ancho y alto del tablero de juego
tablero.ANCHO EQU 10
tablero.ALTO  EQU 5

; Marca un OFFSET o SIZE como no completado
; Esto no lo chequea el ABI enforcer, sirve para saber a simple vista qué cosas
; quedaron sin completar :)
NO_COMPLETADO EQU -1

extern strcmp

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
carta.en_juego EQU 0
carta.nombre   EQU 1
carta.vida     EQU 14
carta.jugador  EQU 16
carta.SIZE     EQU 18

tablero.mano_jugador_rojo EQU 0
tablero.mano_jugador_azul EQU 8
tablero.campo             EQU 16
tablero.SIZE              EQU 416 ;matriz de punteros 400 del tablero mas 16 de antes 10*5*8

accion.invocar   EQU 0
accion.destino   EQU 8
accion.siguiente EQU 16
accion.SIZE      EQU 24

; Variables globales de sólo lectura
section .rodata

; Marca el ejercicio 1 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - hay_accion_que_toque
global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db TRUE

; Marca el ejercicio 2 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - invocar_acciones
global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db TRUE

; Marca el ejercicio 3 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contar_cartas
global EJERCICIO_3_HECHO
EJERCICIO_3_HECHO: db TRUE

section .text

; Dada una secuencia de acciones determinar si hay alguna cuya carta tenga un
; nombre idéntico (mismos contenidos, no mismo puntero) al pasado por
; parámetro.
;
; El resultado es un valor booleano, la representación de los booleanos de C es
; la siguiente:
;   - El valor `0` es `false`
;   - Cualquier otro valor es `true`
;
; ```c
; bool hay_accion_que_toque(accion_t* accion, char* nombre);
; ```
global hay_accion_que_toque
hay_accion_que_toque:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; RDI = accion_t*  accion
	; RSI = char*      nombre

	push rbp
	mov rbp,rsp
	push r12
	push r13
	push r14
	push r15

	mov r12,rdi ;puntero a accion
	mov r13,rsi ;nombre a comparar

while1: 
	cmp r12,0
	je returnFalse

	mov rdi, [r12 + accion.destino] ;rdi = r12->siguiente;
	lea rdi, [rdi + carta.nombre]  ;lea lee la direccion del nombre, mov lee directamente el nombre,lea no accede a memoria

	mov rsi,r13

	call strcmp

	cmp ax,0
	je returnTrue

	mov r12,[r12 + accion.siguiente] ;r12 = accion->siguiente
	jmp while1
	
	
returnFalse: 
	xor rax,rax 
	jmp fin

returnTrue:
	mov rax,1
	jmp fin

fin:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret




; Invoca las acciones que fueron encoladas en la secuencia proporcionada en el
; primer parámetro.
;
; A la hora de procesar una acción esta sólo se invoca si la carta destino
; sigue en juego.
;
; Luego de invocar una acción, si la carta destino tiene cero puntos de vida,
; se debe marcar ésta como fuera de juego.
;
; Las funciones que implementan acciones de juego tienen la siguiente firma:
; ```c
; void mi_accion(tablero_t* tablero, carta_t* carta);
; ```
; - El tablero a utilizar es el pasado como parámetro
; - La carta a utilizar es la carta destino de la acción (`accion->destino`)
;
; Las acciones se deben invocar en el orden natural de la secuencia (primero la
; primera acción, segundo la segunda acción, etc). Las acciones asumen este
; orden de ejecución.
;
; ```c
; void invocar_acciones(accion_t* accion, tablero_t* tablero);
; ```
global invocar_acciones
invocar_acciones:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; RDI = accion_t*  accion
	; RSI = tablero_t* tablero
	push rbp
	mov rbp,rsp
	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp,8

	mov r12,rdi ;puntero a accion
	mov r13,rsi ;puntero a tablero

while2: 
	cmp r12,0
	je fin1

	mov r14, [r12 + accion.destino] ;cartaDestino

	cmp byte[r14 + carta.en_juego],1
	jne sigIteracion 

	mov rbx,[r12 + accion.invocar] ;funcion de invocacion

	mov rdi,r13
	mov rsi,r14

	call rbx

	cmp word[r14 + carta.vida],0
	jne sigIteracion

	mov byte[r14 + carta.en_juego],0

sigIteracion:
	mov r12,[r12 + accion.siguiente] ;r12 = accion->siguiente
	jmp while2
fin1:
	add rsp,8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

; Cuenta la cantidad de cartas rojas y azules en el tablero.
;
; Dado un tablero revisa el campo de juego y cuenta la cantidad de cartas
; correspondientes al jugador rojo y al jugador azul. Este conteo incluye tanto
; a las cartas en juego cómo a las fuera de juego (siempre que estén visibles
; en el campo).
;
; Se debe considerar el caso de que el campo contenga cartas que no pertenecen
; a ninguno de los dos jugadores.
;
; Las posiciones libres del campo tienen punteros nulos en lugar de apuntar a
; una carta.
;
; El resultado debe ser escrito en las posiciones de memoria proporcionadas
; como parámetro.
;
; ```c
; void contar_cartas(tablero_t* tablero, uint32_t* cant_rojas, uint32_t* cant_azules);
; ```
global contar_cartas
contar_cartas:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; RDI = tablero_t* tablero
	; RSI = uint32_t*  cant_rojas
	; RDX = uint32_t*  cant_azules
	push rbp
	mov rbp,rsp

	lea rdi, [rdi + tablero.campo] ;puntero al primer casillero
	mov dword[rsi],0
	mov dword[rdx],0

	xor r8,r8
for:
	cmp r8,tablero.ANCHO*tablero.ALTO
	je fin3

	mov r10,[rdi + r8*8] ;tablero->campo[i][j]
	cmp r10,0
	je sigIteracion1

jugadorAzul:
	cmp byte [r10 + carta.jugador],JUGADOR_AZUL
	jne jugadorRojo 
	inc dword[rdx]
	jmp sigIteracion1
jugadorRojo: 
	cmp byte [r10 + carta.jugador],JUGADOR_ROJO 
	jne sigIteracion1
	inc dword[rsi]

sigIteracion1:
	inc r8
	jmp for

fin3: 
	pop rbp	
	ret
