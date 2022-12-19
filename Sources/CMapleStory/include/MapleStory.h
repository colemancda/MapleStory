//
//  MapleStory.h
//  
//
//  Created by Alsey Coleman Miller on 12/16/22.
//

#ifndef MapleStory_h
#define MapleStory_h

#include <stdio.h>
#include <stdint.h>

/// MapleStory Encryption
void maple_encrypt(uint8_t* buf, int32_t nbytes);

/// MapleStory Decrypt
void maple_decrypt(uint8_t* buf, int32_t nbytes);

#endif /* MapleStory_h */
