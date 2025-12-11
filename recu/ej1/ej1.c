#include "../ejs.h"
#include <string.h>

bool encontrarTesoroEnMapa(Mapa *mapa, Recorrido *rec, uint64_t *acciones_ejecutadas) {
    if (mapa == NULL || rec == NULL) {
        return false;
    }
    *acciones_ejecutadas = 0;

    uint32_t idHabActual = mapa->id_entrada;

    if (mapa->habitaciones[idHabActual].contenido.es_tesoro) {
        return true;
    }
    
    for (uint64_t i = 0; i < rec->cant_acciones; i++) {

        Accion proxAccion = rec->acciones[i];
        uint32_t idVecino = mapa->habitaciones[idHabActual].vecinos[proxAccion];
 
        if (idVecino == 99) {
            return false;
        }
        idHabActual = idVecino;
        *acciones_ejecutadas += 1;

        if (mapa->habitaciones[idHabActual].contenido.es_tesoro) {
            return true;
        }
    }
    return false;
}