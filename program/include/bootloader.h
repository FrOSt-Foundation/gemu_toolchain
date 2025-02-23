#pragma once

#include "types.h"

struct Device {
    u16 id;
    u16 hardwareIDA;
    u16 hardwareIDB;
    u16 hardwareVersion;
    u16 manufacturerIDA;
    u16 manufacturerIDB;
} __attribute__ ((packed));

struct DeviceList {
    u16 size;
    struct Device devices[];
} __attribute__ ((packed));
