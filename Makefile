CC = tools/clang
AS = tools/assembler

CFLAGS = -MP -MD -ccc-host-triple dcpu16 -Oz -Weverything -fcolor-diagnostics -std=c11 -Wno-shadow
SFLAGS = --remove-unused

ROM = rom.dasm
BIN_ROM = bin/rom.bin

BOOT_FILES_S = $(wildcard boot/*.dasm)
BOOT_INC = -Iboot/ -Ikernel/
BOOT_FLAGS = $(CFLAGS)
BOOT_FILES_C = $(wildcard boot/*.c)
BOOT_FILES_OBJ = $(subst boot, bin/boot, $(BOOT_FILES_C:.c=.c.dasm))
BOOT_FILES_AS = $(BOOT_FILES_S) $(BOOT_FILES_OBJ)

KERNEL_FILES_S = $(wildcard kernel/*.dasm)
KERNEL_INC = -Ikernel/
KERNEL_FLAGS = $(CFLAGS)
KERNEL_FILES_C = $(wildcard kernel/*.c)
KERNEL_FILES_OBJ = $(subst kernel, bin/kernel, $(KERNEL_FILES_C:.c=.c.dasm))
KERNEL_FILES_AS = $(KERNEL_FILES_S) $(KERNEL_FILES_OBJ)

BIN_AS = bin/cFrOSt.dasm
BIN = bin/cFrOSt.bin

all: $(BIN_ROM) $(BIN)

$(BIN): $(BOOT_FILES_AS) $(KERNEL_FILES_AS)
	cat $(BOOT_FILES_AS) $(KERNEL_FILES_AS) > $(BIN_AS)
	$(AS) $< -o $@.noswap
	dd conv=swab < $@.noswap > $@

$(BIN_ROM): $(ROM)
	mkdir -p bin
	$(AS) $< -o $@

bin/boot/%.c.dasm: boot/%.c
	$(CC) $(BOOT_FLAGS) $(BOOT_INC) $< -S $@

bin/kernel/%.c.dasm: kernel/%.c
	$(CC) $(KERNEL_FLAGS) $(KERNEL_INC) $< -S $@

clean:
	rm -rf bin/*

run: all
	./GEMUSingle -nofliprom -rom $(BIN_ROM) -floppy $(BIN)
