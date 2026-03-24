//
//  ChangeChannelNotification.swift
//
//

import Foundation

public struct ChangeChannelNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .changeChannel }

    public let responseCode: UInt8
    public let address: [UInt8]
    public let port: UInt16

    public init(
        responseCode: UInt8 = 1,
        address: [UInt8],
        port: UInt16
    ) {
        precondition(address.count == 4, "IPv4 address must be exactly 4 bytes")
        self.responseCode = responseCode
        self.address = address
        self.port = port
    }
}

extension ChangeChannelNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(responseCode)
        try container.encode(address)
        try container.encode(port, isLittleEndian: true)
    }
}

