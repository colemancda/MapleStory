//
//  DenyPartyRequestHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct DenyPartyRequestHandler: PacketHandler {

    public typealias Packet = MapleStory62.DenyPartyRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Deny party invitation
        // Send rejection notification to inviter
        // For now, just silently reject (no notification sent)

        // In a full implementation, we would:
        // 1. Look up the party invitation
        // 2. Send a rejection notification to the party leader
        // 3. Remove the pending invitation
    }
}
