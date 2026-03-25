//
//  SelectAllCharactersHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/23/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles character selection from the all-servers character list.
///
/// When a player is viewing their characters across all worlds (all-servers mode),
/// they can select a character to log in with. This handler processes that selection
/// and initiates the login process for the chosen character.
///
/// # All-Servers Mode
///
/// Some MapleStory regions support an "all servers" view where a player
/// can see characters from all their worlds in a single list. This handler
/// processes character selection from that view.
///
/// # Selection Flow
///
/// 1. Player views all-servers character list
/// 2. Player selects a character
/// 3. Client sends select character request
/// 4. Server validates the character belongs to the account
/// 5. Server initiates channel connection
/// 6. Client transitions to the channel server
///
/// # Response
///
/// Sends `SelectCharacterResponse` directing the client to connect
/// to the appropriate channel server IP and port.
public struct SelectAllCharactersHandler: PacketHandler {

    public typealias Packet = MapleStory62.AllCharactersSelectRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let response = try await selectCharacter(packet, connection: connection)
        try await connection.send(response)
    }
}

internal extension SelectAllCharactersHandler {

    func selectCharacter<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory62.AllCharactersSelectRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory62.ServerIPResponse {
        // Resolve the world from the packet (client sends world index, not state)
        guard let world = try await World.fetch(
            index: request.world,
            version: connection.version,
            region: connection.region,
            in: connection.database
        ) else {
            throw MapleStoryError.invalidWorld
        }
        // Set world on connection state so selectCharacter can find it
        await connection.setWorld(world.id)
        // Pick the first available channel
        guard let channel = try await connection.database.fetch(
            Channel.self,
            predicate: FetchRequest.Predicate(predicate: Channel.Predicate.world(world.id)),
            fetchLimit: 1
        ).first else {
            throw MapleStoryError.invalidChannel
        }
        await connection.setChannel(channel.id)
        let resultChannel = try await connection.selectCharacter(request.character)
        return .init(address: resultChannel.address, character: request.character)
    }
}
