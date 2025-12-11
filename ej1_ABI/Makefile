CC=cc
CFLAGS= -std=c11 -Wall -Wextra -pedantic -O0 -g -lm -Wno-unused-variable -Wno-unused-parameter -no-pie -z noexecstack -I ../
NASM=nasm
NASMFLAGS=-f elf64 -g -F DWARF

all: main

ASM_OBJS := ejercicio_ABI_asm.o ejercicio_ABI_c.o

main: main.o $(ASM_OBJS)
	$(CC) $(CFLAGS) $^ -o $@

main.o: main.c
	$(CC) $(CFLAGS) -c $< -o $@

ejercicio_ABI_c.o: ejercicio_ABI.c
	$(CC) $(CFLAGS) -c $< -o $@

ejercicio_ABI_asm.o: ejercicio_ABI.asm
	$(NASM) $(NASMFLAGS) $< -o $@

clean:
	rm -f *.o
	rm -f main

.PHONY: clean