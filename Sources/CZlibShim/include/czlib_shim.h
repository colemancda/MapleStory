#ifndef CZLIB_SHIM_H
#define CZLIB_SHIM_H

#include <stddef.h>
#include <stdint.h>

/// Inflate a raw DEFLATE stream (no zlib header/trailer) into `dst`.
/// Returns the number of decompressed bytes, or a negative value on error.
long wz_raw_inflate(const uint8_t *src, long src_len, uint8_t *dst, long dst_cap);

#endif
