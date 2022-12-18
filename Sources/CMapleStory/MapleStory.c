//
//  MapleStory.c
//  
//
//  Created by Alsey Coleman Miller on 12/16/22.
//

#include "MapleStory.h"

uint8_t rol(uint8_t v, uint8_t n)
{
    uint8_t msb;

    for(uint8_t i = 0; i < n; ++i)
    {
        msb = v & 0x80 ? 1 : 0;
        v <<= 1;
        v |= msb;
    }

    return v;
}

uint8_t ror(uint8_t v, uint8_t n)
{
    uint8_t lsb;

    for(uint8_t i = 0; i < n; ++i)
    {
        lsb = v & 1 ? 0x80 : 0;
        v >>= 1;
        v |= lsb;
    }

    return v;
}

void maple_encrypt(uint8_t* buf, int32_t nbytes)
{
    int32_t j;
    uint8_t a, c;

    for (uint8_t i = 0; i < 3; ++i)
    {
        a = 0;

        for (j = nbytes; j > 0; --j)
        {
            c = buf[nbytes - j];
            c = rol(c, 3);
            c = (uint8_t)((int32_t)c + j);
            c ^= a;
            a = c;
            c = ror(a, j);
            c ^= 0xFF;
            c += 0x48;
            buf[nbytes - j] = c;
        }

        a = 0;

        for (j = nbytes; j > 0; --j)
        {
            c = buf[j - 1];
            c = rol(c, 4);
            c = (uint8_t)((int32_t)c + j);
            c ^= a;
            a = c;
            c ^= 0x13;
            c = ror(c, 3);
            buf[j - 1] = c;
        }
    }
}

void maple_decrypt(uint8_t* buf, int32_t nbytes)
{
    int32_t j;
    uint8_t a, b, c;

    for (uint8_t i = 0; i < 3; ++i)
    {
        a = 0;
        b = 0;

        for (j = nbytes; j > 0; --j)
        {
            c = buf[j - 1];
            c = rol(c, 3);
            c ^= 0x13;
            a = c;
            c ^= b;
            c = (uint8_t)((int32_t)c - j);
            c = ror(c, 4);
            b = a;
            buf[j - 1] = c;
        }

        a = 0;
        b = 0;

        for (j = nbytes; j > 0; --j)
        {
            c = buf[nbytes - j];
            c -= 0x48;
            c ^= 0xFF;
            c = rol(c, j);
            a = c;
            c ^= b;
            c = (uint8_t)((int32_t)c - j);
            c = ror(c, 3);
            b = a;
            buf[nbytes - j] = c;
        }
    }
}

uint32_t maple_encrypted_hdr(uint8_t* iv, uint16_t nbytes, uint16_t version)
{
    uint16_t* high_iv = (uint16_t*)(iv + 2);
    uint16_t lowpart = *high_iv;
    
    version = 0xFFFF - version;
    lowpart ^= version;

    uint16_t hipart = lowpart ^ nbytes;

    return (uint32_t)lowpart | ((uint32_t)hipart << 16);
}
