CC = tools/clang
AS = tools/assembler

CFLAGS = -MP -MD -ccc-host-triple dcpu16 -Oz -std=c11
SFLAGS = --remove-unused

BOOTLOADER = KISS_bootloader/bootloader.dasm
BIN_BOOTLOADER = bin/bootloader.bin

BOOT_FILES_S = $(wildcard boot/*.dasm)
BOOT_INC = -Iboot/ -Iprogram/
BOOT_FLAGS = $(CFLAGS)
BOOT_FILES_C = $(wildcard boot/*.c)
BOOT_FILES_OBJ = $(subst boot, bin/boot, $(BOOT_FILES_C:.c=.c.dasm))
BOOT_FILES_AS = $(BOOT_FILES_S) $(BOOT_FILES_OBJ)

KERNEL_FILES_S = $(wildcard program/*.dasm)
KERNEL_INC = -Iprogram/
KERNEL_FLAGS = $(CFLAGS)
KERNEL_FILES_C = $(wildcard program/*.c)
KERNEL_FILES_OBJ = $(subst program, bin/program, $(KERNEL_FILES_C:.c=.c.dasm))
KERNEL_FILES_AS = $(KERNEL_FILES_S) $(KERNEL_FILES_OBJ)

BIN_AS = bin/program.dasm
BIN = bin/program.bin

BOOTSECTOR = KISS_bootloader/bootsector.dasm
BIN_BOOTSECTOR = bin/bootsector.bin.noswap

SECTOR_SIZE = 1024

.PHONY: all clean run

-include $(BOOT_FILES_AS KERNEL_FILES_AS:.s=.d)

all: $(BIN_BOOTLOADER) $(BIN)

$(BIN): $(BIN_BOOTSECTOR) $(BIN).nobootsector.noswap
	$(shell echo -ne \\x$(shell echo "(" $(shell wc -c $@.nobootsector.noswap | cut -d " " -f1) "+" $(SECTOR_SIZE) "-1)/" $(SECTOR_SIZE) | bc) | dd status=none conv=notrunc bs=1 count=1 of=$(BIN_BOOTSECTOR))
	cat $(BIN_BOOTSECTOR) $@.nobootsector.noswap > $@.noswap
	dd status=none conv=swab < $@.noswap > $@

$(BIN).nobootsector.noswap: $(BOOT_FILES_AS) $(KERNEL_FILES_AS)
	cat $(BOOT_FILES_AS) $(KERNEL_FILES_AS) > $(BIN_AS)
	$(AS) $(SFLAGS) $(BIN_AS) -o $@
	$(AS) $(SFLAGS) $(BIN_AS) --symbols $@.sym

$(BIN_BOOTSECTOR) : $(BOOTSECTOR)
	@mkdir -p bin
	$(AS) $< -o $@

$(BIN_BOOTLOADER): $(BOOTLOADER)
	@mkdir -p bin
	$(AS) $< -o $@

bin/boot/%.c.dasm: boot/%.c
	@mkdir -p bin/boot
	$(CC) $(BOOT_FLAGS) $(BOOT_INC) $< -S -o $@
	@sed -i -re 's/rfi/rfi 0/i' $@
	@sed -i -re "s/_L/_$(shell echo $@ | sed -re 's|/|_|g')/" $@
	@sed -i -re 's/\b(_[a-zA-Z0-9_]+\.s[A-Z]+[0-9]+_[0-9]+)/.\1/g' $@

bin/program/%.c.dasm: program/%.c
	@mkdir -p bin/program
	$(CC) $(KERNEL_FLAGS) $(KERNEL_INC) $< -S -o $@
	@sed -i -re 's/rfi/rfi 0/i' $@
	@sed -i -re "s/_L/_$(shell echo $@ | sed -re 's|/|_|g')/" $@
	@sed -i -re 's/\b(_[a-zA-Z0-9_]+\.s[A-Z]+[0-9]+_[0-9]+)/.\1/g' $@

clean:
	rm -rf bin/*

run: all
	./tools/GEMUSingle -nofliprom -rom $(BIN_BOOTLOADER) -floppy $(BIN)

debug: all
	./tools/emulator --debugger --symbols $(BIN).nobootsector.noswap.sym -d clock -d keyscreen -d m35fd=$(BIN) $(BIN_BOOTLOADER)
