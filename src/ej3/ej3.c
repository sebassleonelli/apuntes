#include "../ejs.h"


tuit_t** trendingTopic(usuario_t* usuario, esTuitSobresaliente_t esTuitSobresaliente) {
    
    // La llamada ahora es válida porque el prototipo está arriba.
    uint32_t cantidad = contarTuitsSobresalientes(usuario, esTuitSobresaliente);
    
    if (cantidad == 0) {
        return NULL; 
    }
    
    tuit_t** arreglo = (tuit_t**)malloc(sizeof(tuit_t*) * (cantidad + 1));
    
    if (arreglo == NULL) {
        return NULL;
    }
    
    uint32_t id_usuario = usuario->id;
    publicacion_t* actual = usuario->feed->first;
    int indice = 0;
    
    while (actual != NULL) {
        tuit_t* tuit = actual->value;
        
        if (tuit != NULL && tuit->id_autor == id_usuario) {
            
            if (esTuitSobresaliente(tuit) == 1) {
                arreglo[indice] = tuit;
                indice++;
            }
        }
        
        actual = actual->next;
    }
    
    arreglo[indice] = NULL;
    
    return arreglo;
}

// --- 4. Implementación de la Función Auxiliar ---

static uint32_t contarTuitsSobresalientes(const usuario_t* usuario, esTuitSobresaliente_t esTuitSobresaliente) {
    uint32_t contador = 0;
    
    if (!usuario || !usuario->feed || !usuario->feed->first) {
        return 0;
    }
    
    uint32_t id_usuario = usuario->id;
    publicacion_t* actual = usuario->feed->first;
    
    while (actual != NULL) {
        tuit_t* tuit = actual->value;
        
        if (tuit != NULL && tuit->id_autor == id_usuario) {
            
            if (esTuitSobresaliente(tuit) == 1) {
                contador++;
            }
        }
        
        actual = actual->next;
    }
    
    return contador;
}
