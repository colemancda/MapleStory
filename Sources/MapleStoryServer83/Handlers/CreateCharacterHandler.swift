//
//  CreateCharacterHandler.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct CreateCharacterHandler: PacketHandler {
    
    public typealias Packet = MapleStory83.CreateCharacterRequest
    
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws {
        let response = try await createCharacter(packet, connection: connection)
        try await connection.respond(response)
    }
}

internal extension CreateCharacterHandler {
    
    func createCharacter<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory83.CreateCharacterRequest,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws -> MapleStory83.CreateCharacterResponse {
        guard let name = CharacterName(rawValue: request.name),
            let skinColor = SkinColor(rawValue: numericCast(request.skinColor)) else {
            throw MapleStoryError.invalidRequest
        }
        let values = Character.CreationValues(
            name: name,
            face: request.face,
            hair: request.hair,
            hairColor: request.hairColor,
            skinColor: skinColor,
            top: request.top,
            bottom: request.bottom,
            shoes: request.shoes,
            weapon: request.weapon,
            gender: request.gender,
            str: .random(in: 4 ..< 7),
            dex: .random(in: 4 ..< 7),
            int: .random(in: 4 ..< 7),
            luk: .random(in: 4 ..< 7),
            job: .init(initial: request.job)
        )
        let character = try await connection.createCharacter(values)
        return .init(character: .init(character))
    }
}
