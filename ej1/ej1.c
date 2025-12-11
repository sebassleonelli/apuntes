#include "../ejs.h"
#include <string.h>

// Función principal: publicar un tuit
tuit_t *publicar(char *mensaje, usuario_t *user) {
  tuit_t* nuevaPub = malloc(sizeof(tuit_t));

  nuevaPub->id_autor = user->id;
  nuevaPub->favoritos = 0;
  nuevaPub->retuits = 0;

  strcpy(nuevaPub->mensaje,mensaje);

  agregar_al_feed(nuevaPub, user->feed);

  for (int i = 0; i < user->cantSeguidores; i++)
  {
    usuario_t* seguidor_actual = user->seguidores[i];
    agregar_al_feed(nuevaPub, seguidor_actual->feed);
  }  
  return nuevaPub;
  
}


void agregar_al_feed(tuit_t* tuit, feed_t* feed)
{
  publicacion_t* nuevaPub = malloc(sizeof(publicacion_t));

  nuevaPub->value = tuit;
  nuevaPub->next = feed->first;

  feed->first = nuevaPub;
}
