//
//  WzFixtures.swift
//  MapleStoryFileTests
//
//  Byte-level serializers that mirror `WzReader`/`WzProperty`/`WzDirectory`
//  decoding so tests can build minimal, valid WZ archives and property trees
//  entirely in memory (BMS / zero keystream, so strings are XOR-masked only).
//
//  These are the inverse of the decoders under test; used only to construct
//  fixtures, never asserted against directly.
//

import Foundation
@testable import MapleStoryFile

enum WzFixtures {

    // MARK: - Primitives

    static func int32LE(_ value: Int32) -> [UInt8] {
        let u = UInt32(bitPattern: value)
        return [UInt8(u & 0xFF), UInt8((u >> 8) & 0xFF), UInt8((u >> 16) & 0xFF), UInt8((u >> 24) & 0xFF)]
    }

    static func uint32LE(_ u: UInt32) -> [UInt8] {
        [UInt8(u & 0xFF), UInt8((u >> 8) & 0xFF), UInt8((u >> 16) & 0xFF), UInt8((u >> 24) & 0xFF)]
    }

    static func int64LE(_ value: Int64) -> [UInt8] {
        let u = UInt64(bitPattern: value)
        return (0 ..< 8).map { UInt8((u >> ($0 * 8)) & 0xFF) }
    }

    static func floatLE(_ value: Float) -> [UInt8] { uint32LE(value.bitPattern) }

    static func doubleLE(_ value: Double) -> [UInt8] {
        let u = value.bitPattern
        return (0 ..< 8).map { UInt8((u >> ($0 * 8)) & 0xFF) }
    }

    static func compressedInt(_ value: Int32) -> [UInt8] {
        if value >= -127, value <= 127 { return [UInt8(bitPattern: Int8(value))] }
        return [0x80] + int32LE(value)
    }

    static func compressedLong(_ value: Int64) -> [UInt8] {
        if value >= -127, value <= 127 { return [UInt8(bitPattern: Int8(value))] }
        return [0x80] + int64LE(value)
    }

    // MARK: - Strings (BMS / zero keystream)

    /// A length-prefixed, XOR-masked ASCII WZ string (no key, so key[i] == 0).
    static func wzString(_ string: String) -> [UInt8] {
        let scalars = Array(string.utf8)
        if scalars.isEmpty { return [0x00] }
        precondition(scalars.count <= 126, "fixture strings stay short")
        var bytes: [UInt8] = [UInt8(bitPattern: Int8(-scalars.count))]
        var mask: UInt8 = 0xAA
        for byte in scalars {
            bytes.append(byte ^ mask)
            mask = mask &+ 1
        }
        return bytes
    }

    /// A string-block: an inline WZ string tagged `0x00`.
    static func stringBlock(_ string: String) -> [UInt8] {
        [0x00] + wzString(string)
    }

    // MARK: - Property values

    static func property(_ name: String, _ value: [UInt8]) -> [UInt8] {
        stringBlock(name) + value
    }

    static func null() -> [UInt8] { [0x00] }
    static func int16(_ v: Int16) -> [UInt8] { [0x02] + [UInt8(UInt16(bitPattern: v) & 0xFF), UInt8((UInt16(bitPattern: v) >> 8) & 0xFF)] }
    static func int32(_ v: Int32) -> [UInt8] { [0x03] + compressedInt(v) }
    static func int64(_ v: Int64) -> [UInt8] { [0x14] + compressedLong(v) }
    static func float(_ v: Float) -> [UInt8] {
        v == 0 ? [0x04, 0x00] : [0x04, 0x80] + floatLE(v)
    }
    static func double(_ v: Double) -> [UInt8] { [0x05] + doubleLE(v) }
    static func string(_ v: String) -> [UInt8] { [0x08] + stringBlock(v) }

    /// Wrap an extended (`type 9`) payload with its Int32 block-length prefix.
    static func extended(_ payload: [UInt8]) -> [UInt8] {
        [0x09] + int32LE(Int32(payload.count)) + payload
    }

    static func vector(x: Int32, y: Int32) -> [UInt8] {
        extended([0x73] + wzString("Shape2D#Vector2D") + compressedInt(x) + compressedInt(y))
    }

    /// A convex made of the given vector `(x, y)` points.
    static func convex(points: [(Int32, Int32)]) -> [UInt8] {
        var payload: [UInt8] = [0x73] + wzString("Shape2D#Convex2D") + compressedInt(Int32(points.count))
        for (x, y) in points {
            payload += [0x73] + wzString("Shape2D#Vector2D") + compressedInt(x) + compressedInt(y)
        }
        return extended(payload)
    }

    static func uol(_ v: String) -> [UInt8] {
        extended([0x73] + wzString("UOL") + [0x00, 0x00] + wzString(v))
    }

    /// A sub-property container (`Property`), holding a serialized property list.
    static func sub(_ entries: [[UInt8]]) -> [UInt8] {
        extended([0x73] + wzString("Property") + [0x00, 0x00] + propertyList(entries))
    }

    /// A `Sound_DX8` whose audio payload is the trailing `audio.count` bytes.
    static func sound(audio: [UInt8], duration: Int32, header: [UInt8] = [0x00, 0x00, 0x00]) -> [UInt8] {
        let payload = [0x73] + wzString("Sound_DX8") + [0x00]
            + compressedInt(Int32(audio.count)) + compressedInt(duration)
            + header + audio
        return extended(payload)
    }

    /// A canvas of the given format/dimensions carrying a zlib bitmap of `rawPixels`.
    static func canvas(width: Int32, height: Int32, format: Int, rawPixels: [UInt8],
                       properties: [[UInt8]] = []) -> [UInt8] {
        let format1 = Int32(format & 0xFF)
        let format2 = Int32((format >> 8) & 0xFF)
        let zlib = zlibStored(rawPixels)
        var payload: [UInt8] = [0x73] + wzString("Canvas") + [0x00]
        if properties.isEmpty {
            payload += [0x00]
        } else {
            payload += [0x01, 0x00, 0x00] + propertyList(properties)
        }
        payload += compressedInt(width) + compressedInt(height)
        payload += compressedInt(format1) + compressedInt(format2)
        payload += [0x00, 0x00, 0x00, 0x00]                 // unknown (skip 4)
        payload += int32LE(Int32(zlib.count + 1))            // length + 1
        payload += [0x00]                                    // unknown (skip 1)
        payload += zlib
        return extended(payload)
    }

    /// A canvas carrying no bitmap data (`dataLength == 0`), used to exercise the
    /// `_inlink`/`_outlink` delegation paths. Optional child properties supplied.
    static func canvasEmpty(width: Int32 = 1, height: Int32 = 1, format: Int = 2,
                            properties: [[UInt8]] = []) -> [UInt8] {
        var payload: [UInt8] = [0x73] + wzString("Canvas") + [0x00]
        if properties.isEmpty {
            payload += [0x00]
        } else {
            payload += [0x01, 0x00, 0x00] + propertyList(properties)
        }
        payload += compressedInt(width) + compressedInt(height)
        payload += compressedInt(Int32(format & 0xFF)) + compressedInt(Int32((format >> 8) & 0xFF))
        payload += [0x00, 0x00, 0x00, 0x00]     // unknown (skip 4)
        payload += int32LE(1)                   // length + 1 == 1 -> dataLength 0
        payload += [0x00]                       // unknown (skip 1)
        return extended(payload)
    }

    /// A minimal zlib stream: `78 9C` header + a single stored DEFLATE block.
    static func zlibStored(_ data: [UInt8]) -> [UInt8] {
        let len = UInt16(data.count)
        let nlen = ~len
        var out: [UInt8] = [0x78, 0x9C, 0x01]
        out += [UInt8(len & 0xFF), UInt8((len >> 8) & 0xFF)]
        out += [UInt8(nlen & 0xFF), UInt8((nlen >> 8) & 0xFF)]
        out += data
        return out
    }

    // MARK: - Property list & image

    /// A property list: a compressed-int count followed by serialized entries.
    static func propertyList(_ entries: [[UInt8]]) -> [UInt8] {
        compressedInt(Int32(entries.count)) + entries.flatMap { $0 }
    }

    /// An image payload: the `0x73` "Property" header followed by a property list.
    static func image(_ entries: [[UInt8]]) -> [UInt8] {
        [0x73] + wzString("Property") + [0x00, 0x00] + propertyList(entries)
    }

    // MARK: - Archive assembly

    /// Encode a 4-byte entry offset the way `WzReader.readOffset()` decodes it.
    static func encodeOffset(_ desired: UInt32, at position: Int, fileStart: UInt32, hash: UInt32) -> [UInt8] {
        var x = (UInt32(truncatingIfNeeded: position) &- fileStart) ^ 0xFFFF_FFFF
        x = x &* hash
        x = x &- WzCrypto.offsetConstant
        x = WzVersion.rotateLeft(x, x & 0x1F)
        let encrypted = x ^ (desired &- (fileStart &* 2))
        return uint32LE(encrypted)
    }

    /// A node in a synthetic archive tree.
    indirect enum Node {
        case image(name: String, payload: [UInt8])
        case directory(name: String, children: [Node])
    }

    /// Build a complete BMS archive from a directory/image tree.
    static func buildArchiveTree(_ roots: [Node], version: Int = 1) -> Data {
        let hash = WzVersion.hash(forVersion: version)
        let fileStart: UInt32 = 17

        var buf: [UInt8] = Array("PKG1".utf8)
        buf += [UInt8](repeating: 0, count: 8)
        buf += [0x11, 0x00, 0x00, 0x00]
        buf += [0x00]                                   // padding -> offset 17
        let marker = WzVersion.encryptedVersion(fromHash: hash)
        buf += [UInt8(marker & 0xFF), UInt8((marker >> 8) & 0xFF)]

        func writeListing(_ nodes: [Node]) {
            buf += compressedInt(Int32(nodes.count))
            var pending: [(node: Node, field: Int)] = []
            for node in nodes {
                switch node {
                case .image(let name, _): buf += [0x04] + wzString(name)
                case .directory(let name, _): buf += [0x03] + wzString(name)
                }
                buf += compressedInt(0) + compressedInt(0)   // size, checksum
                pending.append((node, buf.count))
                buf += [0, 0, 0, 0]                           // offset placeholder
            }
            for entry in pending {
                let target = buf.count
                let encoded = encodeOffset(UInt32(target), at: entry.field, fileStart: fileStart, hash: hash)
                for i in 0 ..< 4 { buf[entry.field + i] = encoded[i] }
                switch entry.node {
                case .image(_, let payload): buf += payload
                case .directory(_, let children): writeListing(children)
                }
            }
        }

        writeListing(roots)
        return Data(buf)
    }

    /// Build a complete BMS archive with root-level images (each already an
    /// `image(...)` payload). Returns the raw archive bytes.
    static func buildArchive(images: [(name: String, payload: [UInt8])], version: Int = 1) -> Data {
        let hash = WzVersion.hash(forVersion: version)
        let fileStart: UInt32 = 17

        // Header: 17 bytes so the version marker sits at offset 17.
        var header: [UInt8] = Array("PKG1".utf8)
        header += [UInt8](repeating: 0, count: 8)   // fileSize (unused by parser)
        header += [0x11, 0x00, 0x00, 0x00]          // fileStart = 17
        header += [0x00]                            // padding to reach offset 17

        var body: [UInt8] = []
        let marker = WzVersion.encryptedVersion(fromHash: hash)
        body += [UInt8(marker & 0xFF), UInt8((marker >> 8) & 0xFF)]
        body += compressedInt(Int32(images.count))

        // Directory entries with placeholder offsets; remember where to patch.
        var offsetFieldPositions: [Int] = []
        for image in images {
            body += [0x04]                          // EntryType.image
            body += wzString(image.name)
            body += compressedInt(0)                // size
            body += compressedInt(0)                // checksum
            offsetFieldPositions.append(header.count + body.count)
            body += [0, 0, 0, 0]                     // offset placeholder
        }

        // Append payloads and patch offsets.
        for (index, image) in images.enumerated() {
            let payloadOffset = header.count + body.count
            body += image.payload
            let encoded = encodeOffset(UInt32(payloadOffset), at: offsetFieldPositions[index],
                                       fileStart: fileStart, hash: hash)
            let fieldStart = offsetFieldPositions[index] - header.count
            for i in 0 ..< 4 { body[fieldStart + i] = encoded[i] }
        }

        return Data(header + body)
    }
}
