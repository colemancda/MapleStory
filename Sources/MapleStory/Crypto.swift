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
            let nbytes = data.count
            var a, c: UInt8
            
            for _ in 0..<3 {
                
                a = 0

                for j in (1...nbytes).reversed() {
                    c = data[nbytes - j]
                    c = c.rotatedLeft(by: 3)
                    c = c &+ UInt8(j)
                    c ^= a
                    a = c
                    c = a.rotatedRight(by: j)
                    c ^= 0xFF
                    c &+= 0x48
                    data[nbytes - j] = c
                }

                a = 0

                for j in (1...nbytes).reversed() {
                    c = data[j - 1]
                    c = c.rotatedLeft(by: 4)
                    c = UInt8(Int(c) + j)
                    c ^= a
                    a = c
                    c ^= 0x13
                    c = c.rotatedRight(by: 3)
                    data[j - 1] = c
                }
            }
        }
        
        static func decrypt(_ data: inout Data) {
            let nbytes = data.count
            var a, b, c: UInt8

             for _ in 0 ..< 3 {
                 a = 0
                 b = 0

                 for j in stride(from: nbytes, to: 0, by: -1) {
                     c = data[j - 1]
                     c = c.rotatedLeft(by: 3)
                     c ^= 0x13
                     a = c
                     c ^= b
                     c = UInt8(Int(c) - j)
                     c = c.rotatedRight(by: -4)
                     b = a
                     data[j - 1] = c
                 }

                 a = 0
                 b = 0

                 for j in stride(from: nbytes, to: 0, by: -1) {
                     c = data[nbytes - j]
                     c -= 0x48
                     c ^= 0xFF
                     c = c.rotatedLeft(by: j)
                     a = c
                     c ^= b
                     c = UInt8(Int(c) - j)
                     c = c.rotatedRight(by: -3)
                     b = a
                     data[nbytes - j] = c
                 }
             }
        }
    }
}
