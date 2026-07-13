//
//  WzReader.swift
//  MapleStoryFile
//
//  Little-endian binary reader with the WZ-specific decoders (compressed ints,
//  encrypted strings, and encrypted offsets), ported from MapleLib's
//  `WzBinaryReader`.
//

import Foundation

public enum WzReaderError: Error {
    case outOfBounds
    case invalidStringBlock(UInt8)
}

public final class WzReader {

    public let data: [UInt8]
    public private(set) var position: Int

    /// String-decryption keystream.
    public let key: WzMutableKey

    /// Header `FStart` (offset where entries begin), used by ``readOffset()``.
    public var fileStart: UInt32 = 0

    /// Version hash, used by ``readOffset()``.
    public var versionHash: UInt32 = 0

    public init(data: [UInt8], key: WzMutableKey, position: Int = 0) {
        self.data = data
        self.key = key
        self.position = position
    }

    public convenience init(data: Data, key: WzMutableKey, position: Int = 0) {
        self.init(data: [UInt8](data), key: key, position: position)
    }

    // MARK: - Cursor

    public func seek(to newPosition: Int) {
        position = newPosition
    }

    public func skip(_ count: Int) {
        position += count
    }

    public var remaining: Int { data.count - position }

    // MARK: - Little-endian primitives

    public func readUInt8() throws -> UInt8 {
        guard position < data.count else { throw WzReaderError.outOfBounds }
        defer { position += 1 }
        return data[position]
    }

    public func readInt8() throws -> Int8 {
        Int8(bitPattern: try readUInt8())
    }

    public func readUInt16() throws -> UInt16 {
        let b0 = UInt16(try readUInt8())
        let b1 = UInt16(try readUInt8())
        return b0 | (b1 << 8)
    }

    public func readInt16() throws -> Int16 {
        Int16(bitPattern: try readUInt16())
    }

    public func readUInt32() throws -> UInt32 {
        let b0 = UInt32(try readUInt8())
        let b1 = UInt32(try readUInt8())
        let b2 = UInt32(try readUInt8())
        let b3 = UInt32(try readUInt8())
        return b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)
    }

    public func readInt32() throws -> Int32 {
        Int32(bitPattern: try readUInt32())
    }

    public func readUInt64() throws -> UInt64 {
        let low = UInt64(try readUInt32())
        let high = UInt64(try readUInt32())
        return low | (high << 32)
    }

    public func readInt64() throws -> Int64 {
        Int64(bitPattern: try readUInt64())
    }

    /// Read `length` raw (unencrypted) ASCII bytes as a string.
    public func readRawString(length: Int) throws -> String {
        guard length >= 0, position + length <= data.count else { throw WzReaderError.outOfBounds }
        let bytes = data[position ..< position + length]
        position += length
        return String(decoding: bytes, as: UTF8.self)
    }

    public func readFloat() throws -> Float {
        Float(bitPattern: try readUInt32())
    }

    public func readDouble() throws -> Double {
        Double(bitPattern: try readUInt64())
    }

    // MARK: - Compressed integers

    /// A single signed byte, or a full `Int32` when the byte is `-128`.
    public func readCompressedInt() throws -> Int32 {
        let flag = try readInt8()
        return flag == Int8.min ? try readInt32() : Int32(flag)
    }

    /// A single signed byte, or a full `Int64` when the byte is `-128`.
    public func readCompressedLong() throws -> Int64 {
        let flag = try readInt8()
        return flag == Int8.min ? try readInt64() : Int64(flag)
    }

    // MARK: - Strings

    /// Read a length-prefixed, XOR-encrypted WZ string.
    public func readWzString() throws -> String {
        let flag = try readInt8()
        if flag == 0 { return "" }
        if flag > 0 {
            let length = flag == Int8.max ? Int(try readInt32()) : Int(flag)
            return try decodeUnicode(length: length)
        } else {
            let length = flag == Int8.min ? Int(try readInt32()) : Int(-Int(flag))
            return try decodeAscii(length: length)
        }
    }

    private func decodeUnicode(length: Int) throws -> String {
        guard length > 0 else { return "" }
        key.ensure(size: length * 2)
        var units = [UInt16](repeating: 0, count: length)
        var mask: UInt16 = 0xAAAA
        for i in 0 ..< length {
            var char = try readUInt16()
            char ^= mask
            char ^= (UInt16(key[i * 2 + 1]) << 8) | UInt16(key[i * 2])
            units[i] = char
            mask = mask &+ 1
        }
        return String(utf16CodeUnits: units, count: length)
    }

    private func decodeAscii(length: Int) throws -> String {
        guard length > 0 else { return "" }
        key.ensure(size: length)
        var bytes = [UInt8](repeating: 0, count: length)
        var mask: UInt8 = 0xAA
        for i in 0 ..< length {
            var byte = try readUInt8()
            byte ^= mask
            byte ^= key[i]
            bytes[i] = byte
            mask = mask &+ 1
        }
        return String(decoding: bytes, as: UTF8.self)
    }

    /// Read a WZ property string that may be inline or a back-reference to an
    /// earlier string at `base + Int32`.
    public func readStringBlock(base: Int) throws -> String {
        let type = try readUInt8()
        switch type {
        case 0x00, 0x73:
            return try readWzString()
        case 0x01, 0x1B:
            let offset = base + Int(try readInt32())
            return try readWzString(at: offset)
        default:
            throw WzReaderError.invalidStringBlock(type)
        }
    }

    /// Read a WZ string located at an absolute `offset`, restoring the cursor.
    public func readWzString(at offset: Int) throws -> String {
        let saved = position
        defer { position = saved }
        position = offset
        return try readWzString()
    }

    // MARK: - Offsets

    /// Decode an encrypted 4-byte entry offset (requires ``fileStart`` and
    /// ``versionHash`` to be set).
    public func readOffset() throws -> UInt32 {
        var offset = UInt32(truncatingIfNeeded: position)
        offset = (offset &- fileStart) ^ 0xFFFF_FFFF
        offset = offset &* versionHash
        offset = offset &- WzCrypto.offsetConstant
        offset = WzVersion.rotateLeft(offset, offset & 0x1F)
        let encrypted = try readUInt32()
        offset ^= encrypted
        offset = offset &+ (fileStart &* 2)
        return offset
    }
}
