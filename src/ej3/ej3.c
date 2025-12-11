#include "../ejs.h"
#include <stdint.h>

usuario_t **
asignarNivelesParaNuevosUsuarios(uint32_t *ids, uint32_t cantidadDeIds,
                                 uint8_t (*deQueNivelEs)(uint32_t)) {
{
  if (cantidadDeIds == 0) return NULL;
  // Asignar memoria para el array de punteros a usuarios
  usuario_t **res = malloc(cantidadDeIds * sizeof(usuario_t*));
  for (int i = 0; i < cantidadDeIds; i++)
  {
    // Asignar memoria para cada nuevo usuario
    usuario_t *new_u = malloc(sizeof(usuario_t));
    uint32_t id = ids[i];
    uint8_t n = deQueNivelEs(id);
    new_u->id = id;
    new_u->nivel = n;
    res[i] = new_u;
  }
  return res;
}
}



