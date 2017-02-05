#pragma once

#include "types.h"

struct Device {
    u16 hwiId;
    u32 hadwareId;
    u16 hardwareVersion;
    u32 manufacturerId;
};

struct DeviceList {
    u16 size;
    struct Device devices[];
};
