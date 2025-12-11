#include "../ejs.h"

producto_t *filtrarPublicacionesNuevasDeUsuariosVerificados(catalogo_t *h) {

    uint32_t cantPubli = contadorDePublicacionesValidas(h->first);
    producto_t** publicacionesValidas = malloc((cantPubli+1)*sizeof(producto_t*));

    publicacion_t* actual = h->first;

    uint32_t i = 0;
    while(actual != NULL){
        if (verificarProducto(actual->value) == 1)
        {
            publicacionesValidas[i] = actual->value;
            i++;
        }
        actual = actual->next;
    }
    publicacionesValidas[i] = NULL;
    return publicacionesValidas; 
    
}

int verificarProducto(producto_t* producto){
    usuario_t* user = producto->usuario;
    if (producto->estado == 1 && user->nivel >= 1)
    {
        return 1;
    }
    return 0; 
}

int contadorDePublicacionesValidas(publicacion_t* pubFirst){
    publicacion_t* actual = pubFirst;
    uint32_t contadorDePublicaciones = 0;
    while (actual!= NULL)
    {
        if(verificarProducto(actual->value) == 1)
        {
            contadorDePublicaciones++;
        }
        actual = actual->next;
    }
    
    return contadorDePublicaciones;
}