#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej2.h"

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - es_indice_ordenado
 */
bool EJERCICIO_2A_HECHO = false;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - contarCombustibleAsignado
 */
bool EJERCICIO_2B_HECHO = false;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - modificarUnidad
 */
bool EJERCICIO_2C_HECHO = true;

/**
 * OPCIONAL: implementar en C
 */
void optimizar(mapa_t mapa, attackunit_t* compartida, uint32_t (*fun_hash)(attackunit_t*)) {
}

/**
 * OPCIONAL: implementar en C
 */
uint32_t contarCombustibleAsignado(mapa_t mapa, uint16_t (*fun_combustible)(char*)) {
}

/**
 * OPCIONAL: implementar en C
 */
void modificarUnidad(mapa_t mapa, uint8_t x, uint8_t y, void (*fun_modificar)(attackunit_t*)) {
	// COMPLETAR
	// Aclaraciones hechas durante el parcial: 
	// - Se puede usar la función strcpy de string.h
	// - Se puede asumir que el char clase[11] termina en 0
	attackunit_t* to_modify = mapa[x][y];
	if (to_modify == 0)
		return;
	if(to_modify->references == 1) {
		fun_modificar(to_modify);
	} else {
		//Hago la copia (nueva instancia)
		to_modify->references -= 1;
		attackunit_t* individual = malloc(sizeof(attackunit_t));
		individual->combustible = to_modify->combustible;
		individual->references = 1;
		strncpy(individual->clase, to_modify->clase, 11);
		
		// Actualizo el mapa
		mapa[x][y] = individual;

		// Modifico la copia
		fun_modificar(individual);
	}
	return;
}