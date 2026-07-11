//
//  WzVersion.swift
//  MapleStoryFile
//
//  WZ version-hash logic, ported from MapleLib's `WzFile` / `WzTool`.
//

import Foundation

public enum WzVersion {

    /// Compute the 32-bit version hash for a decimal WZ version number.
    ///
    /// `hash = Σ (hash * 32 + asciiValue + 1)` over the decimal digits.
    public static func hash(forVersion version: Int) -> UInt32 {
        var hash: UInt32 = 0
        for scalar in String(version).unicodeScalars {
            hash = hash &* 32 &+ UInt32(scalar.value) &+ 1
        }
        return hash
    }

    /// The 2-byte "encrypted version" marker stored in the file header, derived
    /// from a version hash by XOR-folding its 4 bytes against `0xFF`.
    public static func encryptedVersion(fromHash hash: UInt32) -> UInt16 {
        let a = UInt8((hash >> 24) & 0xFF)
        let b = UInt8((hash >> 16) & 0xFF)
        let c = UInt8((hash >> 8) & 0xFF)
        let d = UInt8(hash & 0xFF)
        return UInt16(0xFF ^ a ^ b ^ c ^ d)
    }

    /// Brute-force the version number whose hash matches the header's marker.
    ///
    /// - Returns: The `(version, hash)` pair, or `nil` if none in `range` matches.
    public static func detect(
        encryptedVersion marker: UInt16,
        in range: ClosedRange<Int> = 1...1000
    ) -> (version: Int, hash: UInt32)? {
        for version in range {
            let hash = self.hash(forVersion: version)
            if encryptedVersion(fromHash: hash) == marker {
                return (version, hash)
            }
        }
        return nil
    }

    /// Rotate a 32-bit value left by `n` bits.
    public static func rotateLeft(_ x: UInt32, _ n: UInt32) -> UInt32 {
        let n = n & 31
        if n == 0 { return x }
        return (x << n) | (x >> (32 - n))
    }
}
