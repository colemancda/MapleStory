//
//  NPCTalkMoreRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct NPCTalkMoreRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .npcTalkMore }

    /// Type of the last dialog shown
    public let lastMessageType: UInt8

    /// Button pressed or selection index
    public let action: UInt8

    /// Text returned (when lastMessageType == 2 and action != 0)
    public let returnText: String?

    /// Numeric selection (when not a text input)
    public let selection: Int32?
}

extension NPCTalkMoreRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.lastMessageType = try container.decode(UInt8.self)
        self.action = try container.decode(UInt8.self)
        if lastMessageType == 2 && action != 0 {
            self.returnText = try container.decode(String.self)
            self.selection = nil
        } else if container.remainingBytes >= 4 {
            self.returnText = nil
            self.selection = try container.decode(Int32.self)
        } else if container.remainingBytes >= 1 {
            self.returnText = nil
            self.selection = Int32(try container.decode(UInt8.self))
        } else {
            self.returnText = nil
            self.selection = nil
        }
    }
}
