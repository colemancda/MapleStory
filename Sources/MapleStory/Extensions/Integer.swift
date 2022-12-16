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
    
    /*
     Takes a byte value and an `Int` value `count`, and returns the result of shifting the bits in in to the left by count positions, wrapping around to the right if necessary. The count parameter is first taken modulo 8 to ensure that it is in the range 0 to 7. The value of in is first cast to an int and masked with 0xFF (which is a binary number with 8 ones, representing the lower 8 bits) to ensure that the operation is performed on a positive integer. The value is then shifted left by count positions, and the result is masked with 0xFF to ensure that it fits in a single byte. Finally, the result is cast back to a byte and returned.
     */
    func rollLeft(_ count: Int) -> UInt8 {
        var tmp = Int(self & 0xFF)
        tmp = tmp << (count % 8)
        return UInt8((tmp & 0xFF) | (tmp >> 8))
    }
    
    /*
     Shifts the bits to the right by count positions, wrapping around to the left if necessary. The value of in is first cast to an int and masked with 0xFF, then shifted left by 8 positions to fill the high-order bits. The value is then shifted right by count positions, and the result is masked with 0xFF to ensure that it fits in a single byte. Finally, the result is cast back to a byte and returned.
     */
    func rollRight(_ count: Int) -> UInt8 {
        var tmp = Int(self & 0xFF)
        tmp = (tmp << 8) >> (count % 8)
        return UInt8((tmp & 0xFF) | (tmp >> 8))
    }
}
