//
//  CharInfoRequestHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles requests for character information.
///
/// # Character Info Request
///
/// This handler allows players to view basic information about
/// another character by clicking on them or using the character
/// info command.
///
/// # Character Info Flow
///
/// 1. Player clicks on a character or uses character info command
/// 2. Client sends character info request with character ID
/// 3. Server validates player is logged in
/// 4. Server fetches target character from database
/// 5. Server sends character info message to player
///
/// # Character Info Content
///
/// The returned info includes:
/// - Character name
/// - Character level
/// - Character job
///
/// Format: "[Name] Lv.[Level] [Job]"
///
/// Example: "PlayerName Lv.50 Hermit"
///
/// # Use Cases
///
/// Character info is used for:
/// - **Inspecting players**: Clicking on another player
/// - **Player lookup**: Finding players for party/guild invites
/// - **Level checking**: Verifying player requirements
/// - **Job verification**: Confirming character job
///
/// # Validation
///
/// - Target character must exist
/// - Target character must be in the same world
/// - If character not found, sends "Character not found." message
///
/// # Privacy
///
/// Character info only shows basic public information:
/// - Name, level, job
/// - Does NOT show: HP/MP, equipment, inventory, etc.
/// - More detailed info requires other handlers or GM commands
///
/// # Response
///
/// Sends `ServerMessageNotification.notice` with character info string
public struct CharInfoRequestHandler: PacketHandler {

    public typealias Packet = MapleStory62.CharInfoRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        guard let target = try await Character.fetch(
            packet.characterID,
            world: character.world,
            in: connection.database
        ) else {
            try await connection.send(ServerMessageNotification.notice(message: "Character not found."))
            return
        }

        try await connection.send(ServerMessageNotification.notice(
            message: "\(target.name.rawValue) Lv.\(target.level) \(target.job)"
        ))
    }
}
