#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "ejercicio_ABI.h"

int main() {
	/* Acá pueden realizar sus propias pruebas */

	assert(alternate_sum_4_using_c(10,9,8,7) == 2);

	assert(alternate_sum_8_using_c(10,9,8,7,6,5,4,3) == 4);

	return 0;
}
