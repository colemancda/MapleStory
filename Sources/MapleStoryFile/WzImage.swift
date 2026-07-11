//
//  WzImage.swift
//  MapleStoryFile
//
//  A `.img` entry inside a WZ directory. Property parsing is a later layer; for
//  now this records the entry's location so it can be parsed on demand.
//

import Foundation

public final class WzImage {
    public let name: String
    public let size: Int
    public let checksum: Int
    public let offset: UInt32

    public init(name: String, size: Int, checksum: Int, offset: UInt32) {
        self.name = name
        self.size = size
        self.checksum = checksum
        self.offset = offset
    }
}
