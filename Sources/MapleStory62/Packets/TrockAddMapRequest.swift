//
//  TrockAddMapRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct TrockAddMapRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .trockAddMap }

    /// 0x01 = remove, 0x03 = add
    public let mode: UInt8

    /// Map ID to add (only present when mode == 0x03)
    public let mapID: UInt32?
}

extension TrockAddMapRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.mode = try container.decode(UInt8.self)
        let _ = try container.decode(UInt8.self)
        if mode == 0x03 {
            self.mapID = try container.decode(UInt32.self)
        } else {
            self.mapID = nil
        }
    }
}
