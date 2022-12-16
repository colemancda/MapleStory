//
//  Integer.swift
//
//
//  Created by Alsey Coleman Miller on 12/14/22.
//

internal extension UInt16 {
    
    /// Initializes value from two bytes.
    init(bytes: (UInt8, UInt8)) {
        self = unsafeBitCast(bytes, to: UInt16.self)
    }
    
    /// Converts to two bytes. 
    var bytes: (UInt8, UInt8) {
        return unsafeBitCast(self, to: (UInt8, UInt8).self)
    }
}

internal extension UInt32 {
    
    /// Initializes value from four bytes.
    init(bytes: (UInt8, UInt8, UInt8, UInt8)) {
        
        self = unsafeBitCast(bytes, to: UInt32.self)
    }
    
    /// Converts to four bytes.
    var bytes: (UInt8, UInt8, UInt8, UInt8) {
        return unsafeBitCast(self, to: (UInt8, UInt8, UInt8, UInt8).self)
    }
}

internal extension Int32 {
    
    /// Initializes value from four bytes.
    init(bytes: (UInt8, UInt8, UInt8, UInt8)) {
        
        self = unsafeBitCast(bytes, to: Int32.self)
    }
    
    /// Converts to four bytes.
    var bytes: (UInt8, UInt8, UInt8, UInt8) {
        return unsafeBitCast(self, to: (UInt8, UInt8, UInt8, UInt8).self)
    }
}

internal extension UInt64 {
    
    /// Initializes value from four bytes.
    init(bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)) {
        self = unsafeBitCast(bytes, to: UInt64.self)
    }
    
    /// Converts to eight bytes.
    var bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) {
        return unsafeBitCast(self, to: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8).self)
    }
}

internal extension UInt8 {
    
    /// Performs a left rotation, shifting the bits in self to the left by n places and wrapping around any bits that are shifted past the leftmost bit.
    mutating func rotatedLeft(by n: Int) -> UInt8 {
        var msb: UInt8 = 0
        for _ in 0 ..< n {
            msb = (self & 0x80) != 0 ? 1 : 0
            self <<= 1
            self |= msb
        }
        return self
    }
    
    /// Performs a left rotation, shifting the bits in self to the right by n places and wrapping around any bits that are shifted past the rightmost bit.
    mutating func rotatedRight(by n: Int) -> UInt8 {
        var lsb: UInt8 = 0
        for _ in 0 ..< n {
            lsb = (self & 1) != 0 ? 0x80 : 0
            self >>= 1
            self |= lsb
        }
        return self
    }
}
