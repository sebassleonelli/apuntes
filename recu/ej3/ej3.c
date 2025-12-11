#include "../ejs.h"

uint32_t sumarTesoros(Mapa *mapa, uint32_t actual, bool *visitado) {
    if (mapa == NULL)
    {
        return 0;
    }
    if (actual == 99 || visitado[actual] == 1)
    {
        return 0;
    }
    visitado[actual] = 1;
    uint32_t suma = 0;
    if (mapa->habitaciones[actual].contenido.es_tesoro)
    {
        suma += mapa->habitaciones[actual].contenido.valor;
    }
    for (uint32_t i = 0; i < ACC_CANT; i++)
    {
        uint32_t idVecino = mapa->habitaciones[actual].vecinos[i];
        suma += sumarTesoros(mapa,idVecino,visitado);
    }
    
    return suma;
    
}