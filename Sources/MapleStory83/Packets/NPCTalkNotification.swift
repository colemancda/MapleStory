//
//  NPCTalkNotification.swift
//

import Foundation

/// NPC dialogue / talk notification sent to the client.
///
public struct NPCTalkNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .npcTalk }

    public let unknown: UInt8

    public let npcID: UInt32

    public let messageType: UInt8

    public let speaker: UInt8

    public let text: String
}
