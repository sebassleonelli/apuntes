#include "../ejs.h"

void bloquearUsuario(usuario_t *usuario, usuario_t *usuarioABloquear){

  usuario->bloqueados[usuario->cantBloqueados] = usuarioABloquear;
  usuario->cantBloqueados++;

  borrarFeed(usuario->feed,usuarioABloquear);
  borrarFeed(usuarioABloquear->feed,usuario);

}

void borrarFeed(feed_t *feed, usuario_t *user){
  // Usamos puntero indirecto (puntero a un puntero) para simplificar la lógica de re-enlazar.
  // 'indirecto' apunta al puntero que debemos modificar (ya sea feed->first o anterior->next).
  publicacion_t** indirecto = &(feed->first);

  while(*indirecto != NULL)
  {
    publicacion_t* actual = *indirecto;

    if(actual->value->id_autor == user->id){
      publicacion_t* siguiente = actual->next;
      free(actual);
      *indirecto= siguiente;
    }else
    {
      indirecto = &(actual->next);
    }
  }
}
