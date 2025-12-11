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
bool EJERCICIO_2B_HECHO = true;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - modificarUnidad
 */
bool EJERCICIO_2C_HECHO = false;

/**
 * OPCIONAL: implementar en C
 */
void optimizar(mapa_t mapa, attackunit_t* compartida, uint32_t (*fun_hash)(attackunit_t*)) {
 uint32_t hashCompartida = fun_hash(compartida);
	compartida->references = 0;
    for (int i = 0; i < 255; i++) {
        for (int j = 0; j < 255; j++) {

            attackunit_t* actual = mapa[i][j];

            if (actual == NULL){
                continue;
			}
			if (actual == compartida){
				compartida->references++;
				continue;
			}

            if (fun_hash(actual) == hashCompartida) {
                compartida->references ++;
                mapa[i][j] = compartida;
            }
        }
    }
}


	
/**
 * OPCIONAL: implementar en C
 */
uint32_t contarCombustibleAsignado(mapa_t mapa, uint16_t (*fun_combustible)(char*)) {
	uint32_t reserva = 0;
	for (int i = 0; i < 255; i++)
	{
		for (int j = 0; j < 255; j++)
		{
			attackunit_t* actual = mapa[i][j];
			if (actual == NULL)
			{
				continue;
			}
			uint16_t comBase = fun_combustible(actual->clase);
			uint16_t diferencia =+ actual->combustible - comBase;
			reserva += diferencia;
		}
		
	}
	return reserva;
}

/**
 * OPCIONAL: implementar en C
 */
void modificarUnidad(mapa_t mapa, uint8_t x, uint8_t y, void (*fun_modificar)(attackunit_t*)) {
	// COMPLETAR
	// Aclaraciones hechas durante el parcial: 
	// - Se puede usar la función strcpy de string.h
	// - Se puede asumir que el char clase[11] termina en 0
}