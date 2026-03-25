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

/// Handles party invitation rejections.
///
/// When a player receives a party invitation and declines it, this packet
/// is sent to the server. The server notifies the party leader that the
/// invitation was rejected.
///
/// # Party Invitation Flow
///
/// 1. Party leader invites a player
/// 2. Target player receives invitation popup
/// 3. Target player clicks "Decline"
/// 4. Client sends DenyPartyRequest
/// 5. Server (TODO) notifies party leader of rejection
/// 6. Pending invitation is removed
///
/// # Implementation Status
///
/// Currently silently rejects without notifying the inviter.
///
/// # TODO
///
/// - Look up the pending party invitation
/// - Find the party leader's connection
/// - Send rejection notification to party leader
/// - Remove the pending invitation from PartyRegistry
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
