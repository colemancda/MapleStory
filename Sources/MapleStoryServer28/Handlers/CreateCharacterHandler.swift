//
//  CreateCharacterHandler.swift
//  
//
//  Created by Alsey Coleman Miller on 5/2/24.
//

import Foundation
import CoreModel
import MapleStory28
import MapleStoryServer

public struct CreateCharacterHandler: PacketHandler {
    
    public typealias Packet = MapleStory28.CreateCharacterRequest
    
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let response = try await createCharacter(packet, connection: connection)
        try await connection.send(response)
    }
}

internal extension CreateCharacterHandler {
    
    func createCharacter<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory28.CreateCharacterRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory28.CreateCharacterResponse {
        guard let name = CharacterName(rawValue: request.name),
            let skinColor = SkinColor(rawValue: numericCast(request.skinColor)) else {
            throw MapleStoryError.invalidRequest
        }
        let user = try await connection.user
        let gender = user?.gender ?? .male
        let values = Character.CreationValues(
            name: name,
            face: request.face,
            hair: .init(rawValue: request.hair + request.hairColor),
            skinColor: skinColor,
            top: request.top,
            bottom: request.bottom,
            shoes: request.shoes,
            weapon: request.weapon,
            gender: gender,
            str: numericCast(request.str),
            dex: numericCast(request.dex),
            int: numericCast(request.int),
            luk: numericCast(request.luk),
            job: .beginner
        )
        let character = try await connection.createCharacter(values)
        return .character(.init(character))
    }
}
