#include "../ejs.h"

// Función auxiliar para contar casos por nivel
int contar_casos_por_nivel(caso_t* arreglo_casos, int largo, int nivel) {
    int contador = 0;
    for (int i = 0; i < largo; i++)
    {
        if (arreglo_casos[i].usuario->nivel == nivel)
        {
            contador++;
        }
        
    }
    return contador;


}
segmentacion_t* segmentar_casos(caso_t* arreglo_casos, int largo) {
    segmentacion_t* contadorDeCasos = malloc(sizeof(segmentacion_t));

    if (arreglo_casos == NULL)
        {
            contadorDeCasos->casos_nivel_0 = NULL;
            contadorDeCasos->casos_nivel_1 = NULL;
            contadorDeCasos->casos_nivel_2 = NULL;
            return contadorDeCasos;
        }
    
   int cantidadCasos0 = contar_casos_por_nivel(arreglo_casos,largo,0);
   int cantidadCasos1 = contar_casos_por_nivel(arreglo_casos,largo,1);
   int cantidadCasos2 = contar_casos_por_nivel(arreglo_casos,largo,2);

    caso_t* casos_nivel0;
    caso_t* casos_nivel1;
    caso_t* casos_nivel2;

    if (cantidadCasos0 > 0) {
        casos_nivel0 = malloc(cantidadCasos0 * sizeof(caso_t));
    } else {
        casos_nivel0 = NULL;
    }

    if (cantidadCasos1 > 0) {
        casos_nivel1 = malloc(cantidadCasos1 * sizeof(caso_t));
    } else {
        casos_nivel1 = NULL;
    }

    if (cantidadCasos2 > 0) {
        casos_nivel2 = malloc(cantidadCasos2 * sizeof(caso_t));
    } else {
        casos_nivel2 = NULL;
    }

    int indA = 0;
    int indB = 0;
    int indC = 0;

    for (int i = 0; i < largo; i++)
    {
        usuario_t* userActual = arreglo_casos[i].usuario;
        if (userActual->nivel == 0)
        {
            casos_nivel0[indA] = arreglo_casos[i];
            indA++;
        }
        if (userActual->nivel == 1)
        {
            casos_nivel1[indB] = arreglo_casos[i];
            indB++;
        }
        if (userActual->nivel == 2)
        {
            casos_nivel2[indC] = arreglo_casos[i];
            indC++;
        }
    }
    contadorDeCasos->casos_nivel_0 = casos_nivel0;
    contadorDeCasos->casos_nivel_1 = casos_nivel1;
    contadorDeCasos->casos_nivel_2 = casos_nivel2;

    return contadorDeCasos;
}


