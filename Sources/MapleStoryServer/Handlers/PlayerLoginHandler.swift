//
//  PlayerLoginHandler.swift
//
//
//  Created by Alsey Coleman Miller on 5/3/24.
//

import Foundation
import CoreModel
import MapleStory

public extension MapleStoryServer.Connection {
    
    /// Handle a channel login.
    func playerLogin(
        character characterIndex: Character.Index,
        world: World.ID
    ) async throws -> (user: User, character: Character, channel: Channel, session: Session) {
        
        log("Player Login - Character \(characterIndex)")
        
        let ipAddress = self.address.address
        let loginTime = Date()
        
        let configuration = try await database.fetch(Configuration.self)
        
        // session must already have world specified
        self.state.world = world
        guard let world = try await self.world else {
            throw MapleStoryError.invalidWorld
        }
        
        // fetch session
        guard let character = try await Character.fetch(characterIndex, world: world.id, in: database) else {
            throw MapleStoryError.invalidCharacter
        }
        guard var session = try await Session.fetch(character: character.id, in: database) else {
            throw MapleStoryError.invalidRequest
        }
        guard let channel = try await database.fetch(Channel.self, for: session.channel) else {
            throw MapleStoryError.invalidChannel
        }
        guard let user = try await database.fetch(User.self, for: character.user) else {
            throw MapleStoryError.internalServerError
        }
        
        let timeInterval = session.requestTime.timeIntervalSince(loginTime)
        
        // validate session
        let validateIP = configuration.restrictSessionIP ?? true
        guard session.address == ipAddress || validateIP else {
            throw MapleStoryError.invalidRequest
        }
        
        if let loginExpiration = configuration.loginExpiration {
            guard timeInterval < TimeInterval(loginExpiration) else {
                throw MapleStoryError.sessionExpired
            }
        }
        
        // update session
        session.address = ipAddress
        session.loginTime = loginTime
        try await database.insert(session)
        
        // upgrade connection
        await authenticate(user: user)
        self.state.session = session.id
        self.state.character = session.character
        self.state.channel = session.channel
        await self.setNonce(send: sendNonce, recieve: recieveNonce)
        assert(self.state.world == channel.world)
        assert(character.world == channel.world)
        assert(character.index == characterIndex)
        
        return (user, character, channel, session)
    }
}
