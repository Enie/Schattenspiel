//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#include <stdint.h>

#import "NSImage+MTLTexture.h"

static inline void storeAsF16(float value, uint16_t *pointer) { *(__fp16 *)pointer = value; }
