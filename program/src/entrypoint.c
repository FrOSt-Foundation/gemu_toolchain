#include "bootloader.h"
#include "asm.h"

__attribute__ ((noreturn)) void entrypoint(int mediaHwi, struct DeviceList *list) {
    asm_log(mediaHwi);
    asm_log(list->size);
    while (1);
}
