//
//  WzMutableKey.swift
//  MapleStoryFile
//
//  Lazily-grown AES-256-ECB keystream used to decrypt WZ strings, ported from
//  MapleLib's `WzMutableKey`.
//

import Foundation
import CryptoSwift

/// Generates, on demand, the XOR keystream that decrypts WZ-encoded strings.
///
/// Block 0 is `AES-ECB(IV repeated to 16 bytes)`; each subsequent 16-byte block is
/// `AES-ECB(previous keystream block)`. A zero IV yields an all-zero keystream
/// (private-server / "classic" data with no string encryption).
public final class WzMutableKey {

    private static let batchSize = 4096

    private let iv: [UInt8]
    private let aes: AES
    private let isZeroIV: Bool
    private var keys: [UInt8] = []

    public init(iv: [UInt8], userKey: [UInt8] = WzCrypto.aesUserKey) throws {
        precondition(iv.count == 4)
        self.iv = iv
        self.isZeroIV = (iv[0] | iv[1] | iv[2] | iv[3]) == 0
        self.aes = try AES(key: userKey, blockMode: ECB(), padding: .noPadding)
    }

    public subscript(index: Int) -> UInt8 {
        ensure(size: index + 1)
        return keys[index]
    }

    /// Ensure the keystream is at least `size` bytes long.
    public func ensure(size requested: Int) {
        if keys.count >= requested { return }

        let size = Int((Double(requested) / Double(Self.batchSize)).rounded(.up)) * Self.batchSize

        if isZeroIV {
            keys = [UInt8](repeating: 0, count: size)
            return
        }

        var newKeys = [UInt8](repeating: 0, count: size)
        var start = 0
        if keys.isEmpty == false {
            newKeys.replaceSubrange(0 ..< keys.count, with: keys)
            start = keys.count
        }

        var i = start
        while i < size {
            let block: [UInt8]
            if i == 0 {
                block = (0 ..< 16).map { iv[$0 % 4] }
            } else {
                block = Array(newKeys[(i - 16) ..< i])
            }
            // AES-ECB on a single 16-byte block.
            let encrypted = (try? aes.encrypt(block)) ?? [UInt8](repeating: 0, count: 16)
            newKeys.replaceSubrange(i ..< (i + 16), with: encrypted)
            i += 16
        }
        keys = newKeys
    }
}
