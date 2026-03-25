//
//  NoteActionHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles in-game note (mail) actions between players.
///
/// Players can send notes (short messages) to other players, even when
/// they are offline. Notes are stored and delivered when the recipient
/// next logs in.
///
/// # Note Actions
///
/// - **Send**: Write and send a note to another player by name
/// - **Delete**: Delete received notes
/// - **Read**: Mark note as read
///
/// # Note System
///
/// - Notes are delivered next time recipient logs in
/// - Up to 5 notes can be stored per player (older ones deleted)
/// - Notes can contain text messages only (no items)
///
/// # Implementation Status
///
/// ⚠️ **NOT IMPLEMENTED** — In-game notes system is not yet implemented.
///
/// # TODO
///
/// - Implement note storage in database
/// - Deliver notes on login
/// - Handle note deletion
/// - Notify player when they have unread notes
public struct NoteActionHandler: PacketHandler {

    public typealias Packet = MapleStory62.NoteActionRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // In-game note (mail) read / delete — not yet implemented.
    }
}
