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
