#include "../ejs.h"

Accion invertirAccion(Accion accion);

Recorrido *invertirRecorridoConDirecciones(const Recorrido *rec, uint64_t len) {
    if (rec == NULL || rec->acciones == NULL)
    {
        return NULL;
    }
    Recorrido* vuelta = malloc(sizeof(Recorrido));
    vuelta->cant_acciones = len;

    Accion* arrayDeVuelta = malloc(rec->cant_acciones*sizeof(Accion));

    for (uint64_t i = 0; i < len; i++)
    {
        Accion original = rec->acciones[(len - 1) - i];
        Accion invertida = invertirAccion(original);
        arrayDeVuelta[i] = invertida;
    }
    vuelta->acciones = arrayDeVuelta;
    return vuelta;
}

Accion invertirAccion(Accion accion){
    if (accion == 0)
    {
        return 1;
    }
    if (accion == 1)
    {
        return 0;
    }
    if (accion == 2)
    {
        return 3;
    }
    if (accion == 3)
    {
        return 2;
    } 
}