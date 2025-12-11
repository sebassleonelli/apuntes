#include "../ejs.h"

catalogo_t *removerCopias(catalogo_t *h) {
{
   if (h == NULL)
   {
      return h;
   }
   publicacion_t *actual = h->first;
   if (actual == NULL)
      return h;
   publicacion_t* anterior = NULL;

   while (actual != NULL)
   {
      publicacion_t *revision = h->first;
      producto_t *pa = actual->value;

      while (revision != NULL)
      {
         producto_t *pr = revision->value;
         char *nombrePR = pr -> nombre;
         char *nombrePA = pa -> nombre;

         if ((pr == pa) || strcmp(nombrePR, nombrePA) != 0 || pr->usuario->id != pa->usuario->id){
            anterior = revision;
            revision = revision->next;
            continue;
         }

         free(pr);
         publicacion_t *next = revision -> next;
         anterior -> next = next;
         free(revision);
         revision = next;
      }
      anterior = actual;
      actual = actual->next;

   }

   return h;
   }
} 

