//
//  GeneralChatHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles general chat messages (regular speech bubble).
///
/// # Chat System
///
/// When a player sends a message:
/// 1. Client sends message text
/// 2. Server receives and validates
/// 3. Server broadcasts to all players on the same map
/// 4. Other players see speech bubble with message
///
/// # Chat Features
///
/// - **Speech bubble**: Message appears over player's head
/// - **Map-wide**: All players on map can see
/// - **No filtering**: Messages are broadcast as-is (filtering done elsewhere)
/// - **Player identification**: Character ID and name shown with message
///
/// # Message Display
///
/// - **show flag**: Controls message display behavior
/// - Typically indicates whether to show speech bubble
/// - Messages appear as: "PlayerName: Message"
/// - Message color is typically white/light blue
///
/// # Chat Types
///
/// This handler handles general chat only. Other chat types:
/// - **Buddy chat** (`BuddyChatHandler`): Private messages
/// - **Party chat** (`PartyChatHandler`): Party-only messages
/// - **Guild chat** (`GuildOperationHandler`): Guild-only messages
/// - **Whisper** (`WhisperHandler`): Private 1-on-1 messages
/// - **Spouse chat** (`SpouseChatHandler`): Partner messages
/// - **Messenger** (`MessengerHandler`): Group chat
///
/// # Anti-Cheat
///
/// - Server validates player is logged in
/// - Message length validated by packet structure
/// - Spam filtering done elsewhere (if implemented)
/// - Character ID prevents impersonation
///
/// # Character Name Display
///
/// When displaying chat, clients show:
/// - Character name (not account name)
/// - In the color matching character's chat name setting
/// - With level/job indicators (if enabled in client)
///
/// # Message Format
///
/// Chat messages support:
/// - Regular text
/// - Spaces and punctuation
/// - No command processing (commands start with @ or !)
/// - Multi-line messages (handled by packet structure)
///
/// # Broadcast Range
///
/// Messages are broadcast to:
/// - All players on the same map
/// - NOT to players on other maps
/// - NOT to players in other channels
/// - NOT to players in Cash Shop
///
/// # Server Load Considerations
///
/// Chat generates significant network traffic:
/// - Each message = 1 packet per player on map
/// - 20 players = 20 packets per message
/// - Map with 100 players = 100 packets per message
/// - Popular maps (Henesys) = High packet volume
///
/// # Related Features
///
/// - **Chat filtering**: Block inappropriate words (optional feature)
/// - **Mute system**: Prevent specific players from chatting
/// - **Chat log**: Store messages for moderation (if implemented)
/// - **Report system**: Players can report chat abuse
///
/// # Client-Side Display
///
/// - Messages appear as floating text
/// - Fade out after 5-10 seconds
/// - Multiple messages can queue
/// - Old messages fade as new ones appear
public struct GeneralChatHandler: PacketHandler {

    public typealias Packet = MapleStory62.GeneralChatRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }
        let notification = ChatTextNotification(
            characterID: character.index,
            message: packet.message,
            show: packet.show
        )
        try await connection.broadcast(notification, map: character.currentMap)
    }
}
