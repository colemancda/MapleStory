//
//  SelectCharacterHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import MapleStory

public extension MapleStoryServer.Connection {
    
    /// Select Character
    func selectCharacter(
        _ characterIndex: Character.Index
    ) async throws -> MapleStoryAddress {
        
        log("Select Character \(characterIndex)")
        
        let ipAddress = self.address.address
        let requestTime = Date()
        
        guard let _ = try await self.user else {
            throw MapleStoryError.notAuthenticated
        }
        guard let world = try await self.world else {
            throw MapleStoryError.invalidWorld
        }
        guard var channel = try await self.channel else {
            throw MapleStoryError.invalidChannel
        }
        guard var character = try await Character.fetch(characterIndex, world: world.id, in: database) else {
            throw MapleStoryError.invalidCharacter
        }
        
        // create session
        let session = Session(
            channel: channel.id,
            character: character.id,
            requestTime: requestTime,
            sendNonce: await sendNonce,
            recieveNonce: await recieveNonce,
            address: ipAddress
        )
        try await database.insert(session)
        channel.sessions.append(session.id)
        character.session = session.id
        if let previousSession = character.session {
            channel.sessions.removeAll(where: { $0 == previousSession })
            try await database.delete(Session.self, for: previousSession)
        }
        try await database.insert(channel)
        try await database.insert(character)
        
        return world.address
    }
}
