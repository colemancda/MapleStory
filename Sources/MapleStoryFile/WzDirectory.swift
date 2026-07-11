//
//  WzDirectory.swift
//  MapleStoryFile
//
//  A directory node in a WZ archive tree, ported from MapleLib's `WzDirectory`.
//

import Foundation

public final class WzDirectory {

    public let name: String
    public private(set) var subdirectories: [WzDirectory] = []
    public private(set) var images: [WzImage] = []

    public var size: Int = 0
    public var checksum: Int = 0
    public var offset: UInt32 = 0

    public init(name: String) {
        self.name = name
    }

    /// Entry type tags (see MapleLib `WzDirectoryType`).
    private enum EntryType {
        static let unknown: UInt8 = 1
        static let stringOffset: UInt8 = 2
        static let directory: UInt8 = 3
        static let image: UInt8 = 4
    }

    /// Parse this directory's entries starting at the reader's current position,
    /// then recurse into subdirectories.
    func parse(reader: WzReader) throws {
        guard reader.remaining > 0 else { return }
        let entryCount = Int(try reader.readCompressedInt())
        guard entryCount >= 0, entryCount <= 100_000 else {
            throw WzArchiveError.invalidEntryCount(entryCount)
        }

        for _ in 0 ..< entryCount {
            var type = try reader.readUInt8()
            var name = ""

            switch type {
            case EntryType.unknown:
                _ = try reader.readInt32()
                _ = try reader.readInt16()
                _ = try reader.readOffset()
                continue

            case EntryType.stringOffset:
                let stringOffset = Int(try reader.readInt32())
                let resume = reader.position
                reader.seek(to: Int(reader.fileStart) + stringOffset)
                type = try reader.readUInt8()
                name = try reader.readWzString()
                reader.seek(to: resume)

            case EntryType.directory, EntryType.image:
                name = try reader.readWzString()

            default:
                throw WzArchiveError.unknownEntryType(type)
            }

            let size = Int(try reader.readCompressedInt())
            let checksum = Int(try reader.readCompressedInt())
            let offset = try reader.readOffset()

            if type == EntryType.directory {
                let subdirectory = WzDirectory(name: name)
                subdirectory.size = size
                subdirectory.checksum = checksum
                subdirectory.offset = offset
                subdirectories.append(subdirectory)
            } else {
                images.append(WzImage(name: name, size: size, checksum: checksum, offset: offset))
            }
        }

        // Recurse into subdirectories at their offsets.
        for subdirectory in subdirectories {
            reader.seek(to: Int(subdirectory.offset))
            try subdirectory.parse(reader: reader)
        }
    }
}

public extension WzDirectory {

    /// Depth-first lookup of an image or directory by `/`-separated path.
    subscript(path: String) -> WzImage? {
        let components = path.split(separator: "/").map(String.init)
        guard components.isEmpty == false else { return nil }
        var directory = self
        for component in components.dropLast() {
            guard let next = directory.subdirectories.first(where: { $0.name == component }) else {
                return nil
            }
            directory = next
        }
        return directory.images.first { $0.name == components.last }
    }
}
