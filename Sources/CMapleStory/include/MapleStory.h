//
//  MapleStory.h
//  
//
//  Created by Alsey Coleman Miller on 12/16/22.
//

#ifndef MapleStory_h
#define MapleStory_h

#include <stdio.h>

/// MapleStory Encryption
void maple_encrypt(uint8_t* buf, int32_t nbytes);

/// MapleStory Decrypt
void maple_decrypt(uint8_t* buf, int32_t nbytes);

/// MapleStory Encrypted Header
uint32_t maple_encrypted_hdr(uint8_t* const iv, uint16_t nbytes, uint16_t version);

#endif /* MapleStory_h */
