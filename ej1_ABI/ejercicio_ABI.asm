extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4_using_c
global alternate_sum_8_using_c

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
; Utilizamos la version de los registros de 32 bits, porque la parte alta podria tener basura
; Siempre intenten utilizar los registros que mejor contienen a sus datos.
alternate_sum_4_using_c:
  ;prologo
  push rbp
  mov rbp, rsp
  push r12      ; Guardamos los valores originales de los registros no-volatiles
  push rbx      ; para poder restituirlos despues

  mov ebx, edx  ; Guardamos x3 y x4 en registros no-volatiles para asegurar que
  mov r12d, ecx ; no los perdemos despues de realizar una llamada a otra funcion 

  call restar_c ; LLamamos restar_c | eax = x1-x2 

  mov edi, eax  ; Pasamos el resultado de la resta en EDI para utilizarlo como primer parametro en sumar_c
  mov esi, ebx  ; Pasamos x3 a ESI para utilizarlo como segundo parametro en sumar_C
  call sumar_c

  mov edi, eax  ; Repito la anterior pero con x4.
  mov esi, r12d

  call restar_c

  ;epilogo
  pop rbx       ; Restituyo los valores de los registros no-volatiles que utilizamos para x3 y x4.
  pop r12       ; Noten que los pop se hacen en el orden contrario a los push, esto se debe a como quedan en la pila.
  pop rbp       ; Restituyo el Base Pointer de la funcion que nos llamo.
  ret           ; Al llamar ret, El Stack Pointer debe apuntar a la direccion de retorno que se habia guardado automaticamente
                ; en la pila cuando se llamo call alternate_sum_4_using_c.

; uint32_t alternate_sum_8_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
; x5 --> R8D
; x6 --> R9D
; x7 --> [rpb + 16]
; x8 --> [rpb + 24]
; Como no tenemos suficientes registros, tanto x7 y x8 que "quedaron afuera" se pasan por la pila.
; Se pasan en orden de derecha a izquierda para que en la pila estan ordenadas correctamente.
alternate_sum_8_using_c:
	;prologo
  push rbp            ; Idem ejercicio anterior.
  mov rbp, rsp
  
  push rdx            ; Para este ejercicio, decidimos guardar los valores que utilizaremos en la pila
  push rcx            ; en vez de registros no-volatiles.
  push r8             ; El orden en que los pusheamos no es importante mientras sea consistente.
  push r9             ; No es necesario preocuparnos por x7 o x8 porque ya se encuentran en la pila,
                      ; por lo que tampoco seran modificados.

  call restar_c       ; restar_c nunca modificara los valores que guardamos en nuestro stack_frame,
                      ; asi que estamos seguros que seguiran con su valor original.

  mov edi, eax        ; Idem al ejercicio anterior.
  mov esi, [rbp - 8]  ; Leeremos el valor de x3 directamente desde memoria. [DIRECCION_DE_MEMORIA] indica que
  call sumar_c        ; operaremos con el valor de memoria en DIRECCION_DE_MEMORIA.
                      ; Utilizamos el Base Pointer como base/ancla para direccionar al resto de elementos en la pila.

  mov edi, eax        ; Idem con x4. 
  mov esi, [rbp - 16]
  call restar_c

  mov edi, eax        ; Idem con x5.
  mov esi, [rbp - 24]
  call sumar_c

  mov edi, eax        ; Idem con x6.
  mov esi, [rbp - 32]
  call restar_c

  mov edi, eax        ; Idem con x7, vean que esta "Por debajo" de nuestro Base Pointer, porque pertenece al Stack Frame de
  mov esi, [rbp + 16] ; la funcion que nos llamo.
  call sumar_c

  mov edi, eax        ; Idem con x8.
  mov esi, [rbp + 24]
  call restar_c

	;epilogo
  mov rsp, rbp        ; Como solo guardamos en la pila informacion temporal que no es necesario restaurar,
  pop rbp             ; en vez de popear los valores que apilamos, directamente reiniciamos el Stack Pointer al Base Pointer.
	ret                 ; Luego continuamos el epilogo normalmente.

