//
//  ChannelSessionHandler.swift
//
//
//  Created by Alsey Coleman Miller on 5/3/24.
//


import Foundation
import CoreModel
import MapleStory

public extension MapleStoryServer.Connection {
    
    /// Handle a channel login.
    func startSession(
        for channel: Channel.ID
    ) async throws{
        
        log("Set Channel Encryption")
        
        let ipAddress = self.address.address
        let loginTime = Date()
        
        let configuration = try await database.fetch(Configuration.self)
        
        // fetch session from IP address
        guard let session = try await Session.fetch(address: ipAddress, channel: channel, in: database) else {
            throw MapleStoryError.notAuthenticated
        }
        
        let timeInterval = session.requestTime.timeIntervalSince(loginTime)
        
        // validate session
        if let loginExpiration = configuration.loginExpiration {
            guard timeInterval < TimeInterval(loginExpiration) else {
                throw MapleStoryError.sessionExpired
            }
        }
        
        // set nonce and session
        self.state.session = session.id
        await connection.setNonce(send: session.sendNonce, recieve: session.recieveNonce)
    }
}

public extension MapleStoryServer {
    
    func close(session: Session) async throws {
        // remove from DB
        try await database.delete(Session.self, for: session.id)
        if var character = try await database.fetch(Character.self, for: session.character), character.session == session.id {
            character.session = nil
            try await database.insert(character)
        }
        if var channel = try await database.fetch(Channel.self, for: session.channel), channel.sessions.contains(where: { $0 == session.id }) {
            channel.sessions.removeAll(where: { $0 == session.id })
            try await database.insert(channel)
        }
    }
}
