#include "czlib_shim.h"
#include <zlib.h>
#include <string.h>

long wz_raw_inflate(const uint8_t *src, long src_len, uint8_t *dst, long dst_cap) {
    z_stream s;
    memset(&s, 0, sizeof(s));
    // windowBits = -15 selects raw DEFLATE (no zlib header, no adler32 trailer),
    // which is how WZ stores canvas bitmaps.
    if (inflateInit2(&s, -15) != Z_OK) {
        return -1;
    }
    s.next_in = (Bytef *)src;
    s.avail_in = (uInt)src_len;
    s.next_out = (Bytef *)dst;
    s.avail_out = (uInt)dst_cap;
    int ret = inflate(&s, Z_FINISH);
    long out = (long)s.total_out;
    inflateEnd(&s);
    // WZ raw-deflate streams often lack a clean end-of-stream marker, so inflate
    // reports Z_BUF_ERROR even after producing all bytes. Accept any output.
    if (out > 0) {
        return out;
    }
    if (ret != Z_STREAM_END && ret != Z_OK) {
        return (long)ret - 100;
    }
    return out;
}
