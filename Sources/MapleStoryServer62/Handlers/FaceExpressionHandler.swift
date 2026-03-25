//
//  FaceExpressionHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles player facial expression/emote animations.
///
/// Players can use emotes (facial expressions) that are displayed above
/// their character's head. These are typically triggered via the emote
/// menu or hotkeys. Cash shop face emote items can add additional expressions.
///
/// # Emote System
///
/// Standard emotes include:
/// - **0**: Default/neutral
/// - **1**: Smile
/// - **2**: Angry
/// - **3**: Surprised
/// - **4**: Wink
/// - **5**: Sad
/// - **6**: Confused
/// - **7**: Bored
/// - **8**: Troubled
///
/// # Flow
///
/// 1. Player uses emote (menu or hotkey)
/// 2. Client sends face expression request
/// 3. Server broadcasts facial expression notification to all players on map
/// 4. Each client plays the emote animation above the character
///
/// # Broadcasting
///
/// The expression is broadcast to all players on the current map so
/// everyone can see the emote being performed.
public struct FaceExpressionHandler: PacketHandler {

    public typealias Packet = MapleStory62.FaceExpressionRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }
        try await connection.broadcast(FacialExpressionNotification(
            characterID: character.index,
            expression: packet.emote
        ), map: character.currentMap)
    }
}
