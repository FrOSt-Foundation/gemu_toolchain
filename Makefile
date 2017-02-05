CC = tools/clang
AS = tools/assembler

CFLAGS = -MP -MD -ccc-host-triple dcpu16 -Oz -Weverything -fcolor-diagnostics -std=c11 -Wno-shadow
SFLAGS = --remove-unused

BOOTLOADER = bootloader.dasm
BIN_BOOTLOADER = bin/bootloader.bin

BOOT_FILES_SS = $(wildcard boot/*.dasm)
BOOT_FILES_S = $(filter-out boot/bootsector.dasm, $(BOOT_FILES_SS))
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

BOOTSECTOR = boot/bootsector.dasm
BIN_BOOTSECTOR = bin/bootsector.bin.noswap

SECTOR_SIZE = 1024

all: $(BIN_BOOTLOADER) $(BIN)

$(BIN): $(BIN_BOOTSECTOR) $(BIN).nobootsector.noswap
	$(shell echo -ne \\x$(shell echo "(" $(shell wc -c $@.nobootsector.noswap | cut -d " " -f1) "+" $(SECTOR_SIZE) "-1)/" $(SECTOR_SIZE) | bc) | dd status=none conv=notrunc bs=1 count=1 of=$(BIN_BOOTSECTOR))
	cat $(BIN_BOOTSECTOR) $@.nobootsector.noswap > $@.noswap
	dd status=none conv=swab < $@.noswap > $@

$(BIN).nobootsector.noswap: $(BOOT_FILES_AS) $(KERNEL_FILES_AS)
	cat $(BOOT_FILES_AS) $(KERNEL_FILES_AS) > $(BIN_AS)
	$(AS) $(BIN_AS) -o $@

$(BIN_BOOTSECTOR) : $(BOOTSECTOR)
	$(AS) $< -o $@

$(BIN_BOOTLOADER): $(BOOTLOADER)
	mkdir -p bin
	$(AS) $< -o $@

bin/boot/%.c.dasm: boot/%.c
	$(CC) $(BOOT_FLAGS) $(BOOT_INC) $< -S $@

bin/kernel/%.c.dasm: kernel/%.c
	$(CC) $(KERNEL_FLAGS) $(KERNEL_INC) $< -S $@

clean:
	rm -rf bin/*

run: all
	./GEMUSingle -nofliprom -rom $(BIN_BOOTLOADER) -floppy $(BIN)
