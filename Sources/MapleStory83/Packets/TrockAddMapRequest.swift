//
//  TrockAddMapRequest.swift
//

import Foundation

public struct TrockAddMapRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .trockAddMap }

    /// 0x00 = delete, 0x01 = add current map
    public let type: UInt8

    /// true = VIP trock, false = regular trock
    public let isVIP: Bool

    /// Map ID to delete (only present when type == 0x00)
    public let mapID: UInt32?
}

extension TrockAddMapRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.type = try container.decode(UInt8.self)
        self.isVIP = try container.decode(UInt8.self) == 1
        if type == 0x00 {
            self.mapID = try container.decode(UInt32.self)
        } else {
            self.mapID = nil
        }
    }
}
