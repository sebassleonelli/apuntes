extern malloc
extern strcpy

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text


; Completar las definiciones (serán revisadas por ABI enforcer):
TUIT_MENSAJE_OFFSET EQU 0
TUIT_FAVORITOS_OFFSET EQU 140
TUIT_RETUITS_OFFSET EQU 142 ; 2 de padding
TUIT_ID_AUTOR_OFFSET EQU 144
TUIT_SIZE EQU 148 ;La estructura se alinea al mas grande, en este caso 4 ==> 148/4 = 0 de resto

PUBLICACION_NEXT_OFFSET EQU 0
PUBLICACION_VALUE_OFFSET EQU 8
PUBLICACION_SIZE EQU 16

FEED_FIRST_OFFSET EQU 0 
FEED_SIZE EQU 8

USUARIO_FEED_OFFSET EQU 0;
USUARIO_SEGUIDORES_OFFSET EQU 8
USUARIO_CANT_SEGUIDORES_OFFSET EQU 16; 
USUARIO_SEGUIDOS_OFFSET EQU 24 
USUARIO_CANT_SEGUIDOS_OFFSET EQU 32 
USUARIO_BLOQUEADOS_OFFSET EQU 40; 
USUARIO_CANT_BLOQUEADOS_OFFSET EQU 48 
USUARIO_ID_OFFSET EQU 52; 
USUARIO_SIZE EQU 56 

; void agregar_al_feed(tuit_t* tuit, feed_t* feed)
; Argumentos (ABI):
; rdi: tuit_t* tuit
; rsi: feed_t* feed
; Registros preservados: rbx, rbp, r12, r13, r14, r15
; Registros de uso general: rax, rcx, rdx, r8, r9, r10, r11

section .text
	global agregar_al_feed
	extern malloc

agregar_al_feed:
	; PUSH de registros que usaremos o que la función llamada (malloc) podría corromper
    push rbp
    mov rbp, rsp
    push rbx	; Guardamos rbx (registro callee-saved)
    push r12	; Guardamos r12 (registro callee-saved)
    push r13	; Guardamos r13 (registro callee-saved)
	
	; Guardamos los argumentos: rdi (tuit) en r12, rsi (feed) en r13
	mov r12, rdi ; r12 = tuit
	mov r13, rsi ; r13 = feed

	; 1. Asignación de Memoria para publicacion_t (sizeof(publicacion_t) = 16)
	mov rdi, PUBLICACION_SIZE ; sizeof(publicacion_t)
	call malloc ; rax = puntero a nueva publicacion_t
	
	; Verificación de malloc (Opcional, pero buena práctica)
	; cmp rax, 0
	; je error_malloc

	; 2. Inicialización de la Publicación
	; publicacion_t.next (offset 0) = feed->first (offset 0 de feed)
	mov rcx, [r13]	; rcx = feed->first (publicacion_t*)
	mov [rax], rcx	; nuevaPub->next = feed->first

	; publicacion_t.value (offset 8) = tuit
	mov [rax + 8], r12 ; nuevaPub->value = tuit

	; 3. Actualizar el Feed
	; feed->first (offset 0) = nuevaPub (rax)
	mov [r13], rax ; feed->first = nuevaPub

	; Salto si hay error de malloc (No implementado en esta versión)
	; jmp end

; error_malloc:
	; mov rax, 0 ; Devolver NULL o manejar error

; end:
	; POP de registros
    pop r13
    pop r12
    pop rbx
    pop rbp
	ret ; Retorno de función (void)

; tuit_t* publicar(char* mensaje, usuario_t* usuario)
; Argumentos (ABI):
; rdi: char* mensaje
; rsi: usuario_t* usuario
; Retorno (ABI): rax: tuit_t*

section .text
	global publicar
	extern malloc, strcpy, agregar_al_feed

publicar:
	; PUSH de registros que usaremos o que la función llamada (malloc, strcpy, etc.) podría corromper
    push rbp
    mov rbp, rsp
	
	; El stack debe estar alineado a 16 bytes antes de un 'call'.
	; Como solo haremos un push, usaremos un truco al final o haremos un push más:
    sub rsp, 8  ; Alineamos el stack para los 'call' internos (total 16 bytes de alineación: 8 bytes de rbp + 8 bytes de sub)

	push rbx	; rbx = Puntero al nuevo tuit (Retorno final)
	push r12	; r12 = usuario_t* (Argumento)
	push r13	; r13 = Contador del bucle / Índice
	push r14	; r14 = cantSeguidores
	push r15	; r15 = Puntero base del arreglo de seguidores (usuario_t**)

	; Guardamos los argumentos: rdi (mensaje) en r13, rsi (usuario) en r12
	mov r12, rsi ; r12 = usuario_t*
	mov r13, rdi ; r13 = char* mensaje

	; 1. Asignación de Memoria para tuit_t (sizeof(tuit_t) = 148)
	mov rdi, TUIT_SIZE ; sizeof(tuit_t)
	call malloc ; rax = puntero a nuevo tuit
	
	; Verificación de malloc (Opcional)
	; cmp rax, 0
	; je error_return_null

	mov rbx, rax ; rbx = nuevo_tuit (Lo guardamos para el retorno final)

	; 2. Inicialización del Tuit
	; 2.1. Copiar mensaje (strcpy)
	; Argumentos para strcpy:
	; rdi: Destino (tuit->mensaje, offset 0) -> rbx
	; rsi: Origen (mensaje) -> r13
	mov rdi, rbx 	; rdi = nuevo_tuit
	mov rsi, r13 	; rsi = mensaje (clonado)
	call strcpy 	; Copia el mensaje
	
	; 2.2. Inicializar favoritos (offset 140) y retuits (offset 142) a 0
	; Usamos word (2 bytes) para los uint16_t
	mov word [rbx + TUIT_FAVORITOS_OFFSET], 0 ; tuit->favoritos = 0
	mov word [rbx + TUIT_RETUITS_OFFSET], 0 ; tuit->retuits = 0
	
	; 2.3. Copiar id_autor (offset 144)
	; Leer usuario->id (offset 44)
	mov ecx, dword [r12 + USUARIO_ID_OFFSET] ; ecx = usuario->id
	; Escribir tuit->id_autor (offset 144)
	mov dword [rbx + TUIT_ID_AUTOR_OFFSET], ecx ; tuit->id_autor = usuario->id
	
	; 3. Agregar al Feed Propio
	; Argumentos para agregar_al_feed:
	; rdi: tuit_t* tuit -> rbx
	; rsi: feed_t* feed -> [r12 + 0] (usuario->feed)
	mov rdi, rbx 	; rdi = nuevo_tuit
	mov rsi, [r12] 	; rsi = usuario->feed (offset 0)
	call agregar_al_feed
	
	; 4. Preparación para el Bucle de Seguidores
	; r14 = cantSeguidores (offset 16)
	mov r14d, dword [r12 + USUARIO_CANT_SEGUIDORES_OFFSET] ; r14 = usuario->cantSeguidores
	; r15 = seguidores (offset 8)
	mov r15, qword [r12 + USUARIO_SEGUIDORES_OFFSET]   ; r15 = usuario->seguidores (usuario_t**)
	
	; r13 = índice del bucle (i=0)
	mov r13, 0

loop_seguidores:
	cmp r13, r14 ; Comparar i < cantSeguidores
	jge loop_end ; Si i >= cantSeguidores, terminar bucle

	; Dentro del Bucle:
	; 5.1. Obtener seguidor_actual = user->seguidores[i]
	; Cálculo de la dirección: r15 + r13 * 8 (el tamaño de un puntero es 8 bytes)
	mov rax, r13 	; rax = i
	imul rax, 8 	; rax = i * 8
	add rax, r15 	; rax = &user->seguidores[i]
	mov rdx, [rax] 	; rdx = user->seguidores[i] (usuario_t*)
	
	; 5.2. Llamar a agregar_al_feed(nuevo_tuit, seguidor_actual->feed)
	; Argumentos:
	; rdi: tuit_t* tuit -> rbx
	; rsi: feed_t* feed -> [rdx + 0] (seguidor_actual->feed)
	mov rdi, rbx 	; rdi = nuevo_tuit
	mov rsi, [rdx] 	; rsi = seguidor_actual->feed (offset 0)
	call agregar_al_feed

	; 5.3. i++
	inc r13
	jmp loop_seguidores

loop_end:
	; 6. Retorno
	; El puntero del nuevo tuit ya está en rbx. Lo movemos a rax para el retorno.
	mov rax, rbx 

; error_return_null:
	; Si hubiera un error, rax contendría 0 (NULL)

	; POP y limpieza
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    add rsp, 8 ; Deshacer la alineación del stack
    pop rbp
	ret ; Retorna rax (el puntero a tuit_t)
