//
//  Crypto.swift
//  
//
//  Created by Alsey Coleman Miller on 12/13/22.
//

import Foundation

internal enum Crypto {
    
    enum AES {
        
        
    }
    
    enum Maple {
        
        static func encrypt(_ data: inout Data) {
            
            for j in 0 ..< 6 {
                var remember: UInt8 = 0
                var dataLength = UInt8(data.count & 0xff)
                
                if j % 2 == 0 {
                    for i in 0..<data.count {
                        var cur = data[i]
                        cur = cur.rollLeft(3)
                        cur += dataLength
                        cur ^= remember
                        remember = cur
                        cur = cur.rollRight(Int(dataLength & 0xff))
                        cur = UInt8((~cur) & 0xFF)
                        cur += 0x48
                        dataLength -= 1
                        data[i] = cur
                    }
                } else {
                    for i in (0..<data.count).reversed() {
                        var cur = data[i]
                        cur = cur.rollLeft(4)
                        cur += dataLength
                        cur ^= remember
                        remember = cur
                        cur ^= 0x13
                        cur = cur.rollRight(3)
                        dataLength -= 1
                        data[i] = cur
                    }
                }
            }
        }
        
        static func decrypt(_ data: inout Data) {
            
            for j in 1...6 {
                var remember: UInt8 = 0
                var nextRemember: UInt8 = 0
                var dataLength = UInt8(data.count & 0xff)
                
                if j % 2 == 0 {
                    for i in 0..<data.count {
                        var cur = data[i]
                        cur -= 0x48
                        cur = ~cur
                        cur = cur << UInt8(dataLength & 0xff)
                        nextRemember = cur
                        cur ^= remember
                        remember = nextRemember
                        cur -= dataLength
                        cur = cur >> 3
                        data[i] = cur
                        dataLength -= 1
                    }
                } else {
                    for i in (0..<data.count).reversed() {
                        var cur = data[i]
                        cur = cur << 3
                        cur ^= 0x13
                        nextRemember = cur
                        cur ^= remember
                        remember = nextRemember
                        cur -= dataLength
                        cur = cur >> 4
                        data[i] = cur
                        dataLength -= 1
                    }
                }
            }
        }
    }
}
