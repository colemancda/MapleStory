//
//  SelectCharacterHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/23/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles character selection during the character select screen.
///
/// After a player logs in and sees their character list, they select a character
/// to play. This handler processes that selection and directs the client to the
/// appropriate channel server to begin gameplay.
///
/// # Selection Flow
///
/// 1. Player views their characters on the character select screen
/// 2. Player clicks a character and presses "Enter Game"
/// 3. Client sends select character request
/// 4. Server validates character ownership
/// 5. Server determines which channel to send player to
/// 6. Server sends channel server connection info
/// 7. Client disconnects from login server
/// 8. Client connects to channel server
///
/// # Channel Assignment
///
/// The server selects the least loaded channel for the player.
/// Players can also manually select a specific channel.
///
/// # Response
///
/// Sends `SelectCharacterResponse` with:
/// - **IP address**: Channel server IP to connect to
/// - **port**: Channel server port number
/// - **characterID**: The selected character's ID
///
/// # Security
///
/// - Character must belong to the logged-in account
/// - Session token is generated for channel server authentication
/// - Login server session is maintained until channel connection confirmed
public struct SelectCharacterHandler: PacketHandler {

    public typealias Packet = MapleStory62.CharacterSelectRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let response = try await selectCharacter(packet, connection: connection)
        try await connection.send(response)
    }
}

internal extension SelectCharacterHandler {

    func selectCharacter<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory62.CharacterSelectRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory62.ServerIPResponse {
        let channel = try await connection.selectCharacter(request.character)
        return .init(address: channel.address, character: request.character)
    }
}
