#include "../ejs.h"

void resolver_automaticamente(funcionCierraCasos_t* funcion, caso_t* arreglo_casos, caso_t* casos_a_revisar, int largo){
    int indiceRevisar = 0;
    for (int i = 0; i < largo; i++)
    {
        if (arreglo_casos[i].usuario ->nivel == 1 || arreglo_casos[i].usuario ->nivel == 2)
        {
            int estado = funcion(&arreglo_casos[i]);
            if (estado == 1)
            {
                arreglo_casos[i].estado = 1;
            }else
            {
                if (strncmp(arreglo_casos[i].categoria,"CLT",3)==0 && arreglo_casos[i].categoria[3] == '\0'|| strncmp(arreglo_casos[i].categoria,"RBO",3)==0 && arreglo_casos[i].categoria[3] == '\0'){

                    arreglo_casos[i].estado = 2;
                    casos_a_revisar[indiceRevisar++] = arreglo_casos[i]; 
                }
            }
        }else{
            casos_a_revisar[indiceRevisar++] = arreglo_casos[i];
        }
        
    }
        

}

