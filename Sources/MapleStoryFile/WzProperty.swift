//
//  WzProperty.swift
//  MapleStoryFile
//
//  The value tree inside a WZ `.img`, ported from MapleLib's `WzImageProperty`
//  hierarchy. Canvas *pixel* decoding is a later layer; canvas nodes here capture
//  dimensions/format and the location of the compressed bitmap.
//

import Foundation

/// A named WZ property.
public struct WzNamedProperty: Sendable {
    public let name: String
    public let value: WzProperty
}

/// A WZ property value.
public indirect enum WzProperty: Sendable {
    case null
    case int16(Int16)
    case int32(Int32)
    case int64(Int64)
    case float(Float)
    case double(Double)
    case string(String)
    case vector(x: Int32, y: Int32)
    case sub([WzNamedProperty])
    case convex([WzProperty])
    case uol(String)
    case canvas(WzCanvas)
    case sound
}

/// Canvas metadata plus the location of its (still-compressed) bitmap.
public struct WzCanvas: Sendable {
    public let width: Int
    public let height: Int
    public let format: Int
    public let scale: Int
    public let properties: [WzNamedProperty]
    /// Absolute offset of the compressed bitmap payload within the archive.
    public let dataOffset: Int
    /// Length in bytes of the compressed bitmap payload.
    public let dataLength: Int
}

extension WzProperty {

    /// Parse a WZ property list beginning at the reader's current position.
    /// `base` is the image offset used to resolve string back-references.
    static func parseList(reader: WzReader, base: Int) throws -> [WzNamedProperty] {
        let entryCount = Int(try reader.readCompressedInt())
        var properties: [WzNamedProperty] = []
        properties.reserveCapacity(max(0, entryCount))
        for _ in 0 ..< entryCount {
            let name = try reader.readStringBlock(base: base)
            let type = try reader.readUInt8()
            let value = try parseValue(type: type, reader: reader, base: base, name: name)
            properties.append(WzNamedProperty(name: name, value: value))
        }
        return properties
    }

    private static func parseValue(type: UInt8, reader: WzReader, base: Int, name: String) throws -> WzProperty {
        switch type {
        case 0:
            return .null
        case 2, 11:
            return .int16(try reader.readInt16())
        case 3, 19:
            return .int32(try reader.readCompressedInt())
        case 20:
            return .int64(try reader.readCompressedLong())
        case 4:
            let floatType = try reader.readUInt8()
            return .float(floatType == 0x80 ? try reader.readFloat() : 0)
        case 5:
            return .double(try reader.readDouble())
        case 8:
            return .string(try reader.readStringBlock(base: base))
        case 9:
            let blockSize = Int(try reader.readUInt32())
            let endOfBlock = reader.position + blockSize
            let value = try parseExtended(reader: reader, base: base)
            if reader.position != endOfBlock {
                reader.seek(to: endOfBlock)
            }
            return value
        default:
            throw WzReaderError.invalidStringBlock(type)
        }
    }

    private static func parseExtended(reader: WzReader, base: Int) throws -> WzProperty {
        let tag = try reader.readUInt8()
        let identifier: String
        switch tag {
        case 0x01, 0x1B:
            identifier = try reader.readWzString(at: base + Int(try reader.readInt32()))
        case 0x00, 0x73:
            identifier = try reader.readWzString()
        default:
            throw WzReaderError.invalidStringBlock(tag)
        }
        return try extract(identifier: identifier, reader: reader, base: base)
    }

    private static func extract(identifier: String, reader: WzReader, base: Int) throws -> WzProperty {
        switch identifier {
        case "Property":
            reader.skip(2) // reserved
            return .sub(try parseList(reader: reader, base: base))
        case "Shape2D#Vector2D":
            let x = try reader.readCompressedInt()
            let y = try reader.readCompressedInt()
            return .vector(x: x, y: y)
        case "Shape2D#Convex2D":
            let count = Int(try reader.readCompressedInt())
            var items: [WzProperty] = []
            for _ in 0 ..< count {
                items.append(try parseExtended(reader: reader, base: base))
            }
            return .convex(items)
        case "Sound_DX8":
            return .sound
        case "UOL":
            reader.skip(1)
            switch try reader.readUInt8() {
            case 0:
                return .uol(try reader.readWzString())
            case 1:
                return .uol(try reader.readWzString(at: base + Int(try reader.readInt32())))
            default:
                throw WzReaderError.invalidStringBlock(0xFF)
            }
        case "Canvas":
            return try parseCanvas(reader: reader, base: base)
        default:
            // Unknown extended type: caller seeks to end-of-block, so return null.
            return .null
        }
    }

    private static func parseCanvas(reader: WzReader, base: Int) throws -> WzProperty {
        reader.skip(1)
        var properties: [WzNamedProperty] = []
        if try reader.readUInt8() == 1 {
            reader.skip(2)
            properties = try parseList(reader: reader, base: base)
        }
        let width = Int(try reader.readCompressedInt())
        let height = Int(try reader.readCompressedInt())
        let format = Int(try reader.readCompressedInt())
        let scale = Int(try reader.readUInt8())
        _ = try reader.readInt32() // unknown (0)
        let length = Int(try reader.readInt32()) - 1
        reader.skip(1) // unknown
        let dataOffset = reader.position
        // The compressed bitmap follows; the caller's end-of-block seek skips it.
        return .canvas(WzCanvas(
            width: width,
            height: height,
            format: format,
            scale: scale,
            properties: properties,
            dataOffset: dataOffset,
            dataLength: max(0, length)
        ))
    }
}
