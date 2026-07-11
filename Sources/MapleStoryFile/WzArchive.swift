//
//  WzArchive.swift
//  MapleStoryFile
//
//  Opens a WZ archive: parses the header, detects the version hash, and reads the
//  directory tree. Ported from MapleLib's `WzFile`. Targets the "classic" (non
//  64-bit) header used by v83-era clients.
//

import Foundation

public enum WzArchiveError: Error {
    case invalidHeader
    case versionDetectionFailed(marker: UInt16)
    case invalidEntryCount(Int)
    case unknownEntryType(UInt8)
}

/// The `PKG1` header of a WZ archive.
public struct WzHeader: Sendable, Equatable {
    public var ident: String
    public var fileSize: UInt64
    public var fileStart: UInt32
    public var copyright: String
}

/// A parsed WZ archive.
public final class WzArchive {

    public let header: WzHeader
    public let mapleVersion: WzMapleVersion
    public let version: Int
    public let versionHash: UInt32
    public let root: WzDirectory

    private let reader: WzReader

    /// Open and fully parse a WZ archive.
    ///
    /// - Parameters:
    ///   - version: the MapleStory patch version, or `nil` to brute-force it from
    ///     the header's encrypted-version marker.
    public init(data: Data, mapleVersion: WzMapleVersion, version: Int? = nil) throws {
        let key = try WzMutableKey(iv: mapleVersion.initializationVector)
        let reader = WzReader(data: data, key: key)
        self.reader = reader

        // Header
        let ident = try reader.readRawString(length: 4)
        let fileSize = try reader.readUInt64()
        let fileStart = try reader.readUInt32()
        guard fileStart >= 17 else { throw WzArchiveError.invalidHeader }
        let copyright = try reader.readRawString(length: Int(fileStart) - 17)
        self.header = WzHeader(ident: ident, fileSize: fileSize, fileStart: fileStart, copyright: copyright)

        reader.fileStart = fileStart

        // Encrypted-version marker sits at fileStart.
        reader.seek(to: Int(fileStart))
        let marker = try reader.readUInt16()

        let resolvedVersion: Int
        let resolvedHash: UInt32
        if let version {
            resolvedVersion = version
            resolvedHash = WzVersion.hash(forVersion: version)
        } else {
            guard let detected = WzVersion.detect(encryptedVersion: marker) else {
                throw WzArchiveError.versionDetectionFailed(marker: marker)
            }
            resolvedVersion = detected.version
            resolvedHash = detected.hash
        }
        self.version = resolvedVersion
        self.versionHash = resolvedHash
        self.mapleVersion = mapleVersion
        reader.versionHash = resolvedHash

        // The root directory begins immediately after the 2-byte marker.
        let root = WzDirectory(name: ident)
        try root.parse(reader: reader)
        self.root = root
    }

    /// Parse the property tree of an image (`.img`) entry on demand.
    public func properties(of image: WzImage) throws -> [WzNamedProperty] {
        reader.seek(to: Int(image.offset))
        let header = try reader.readUInt8()
        guard header == 0x73 else { throw WzArchiveError.unknownEntryType(header) }
        let identifier = try reader.readWzString()
        _ = try reader.readUInt16()
        guard identifier == "Property" else { throw WzArchiveError.invalidHeader }
        return try WzProperty.parseList(reader: reader, base: Int(image.offset))
    }
}
