#pragma once

#include "types.h"
#include "bootloader.h"

u16 asm_iag (void);
void asm_ias (u16);
void asm_iaq (u16);
u16 asm_hwn (void);
struct Device asm_hwq (u16);
void asm_hwi (u16);
void asm_log (u16);
void asm_brk (u16);
__attribute__ ((noreturn)) void asm_hlt (void);
