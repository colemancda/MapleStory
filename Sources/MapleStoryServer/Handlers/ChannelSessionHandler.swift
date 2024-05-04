//
//  ChannelSessionHandler.swift
//
//
//  Created by Alsey Coleman Miller on 5/3/24.
//


import Foundation
import CoreModel
import MapleStory

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
