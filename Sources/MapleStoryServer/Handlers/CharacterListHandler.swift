//
//  CharacterListHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import MapleStory
import CoreModel

public extension MapleStoryServer.Connection {
    
    func characterList(
        world worldIndex: World.Index,
        channel channelIndex: Channel.Index
    ) async throws -> [Character] {
        log("Character List - World \(worldIndex) Channel \(channelIndex)")
        guard let user = self.state.user else {
            throw MapleStoryError.notAuthenticated
        }
        guard let world = try await World.fetch(
            index: worldIndex,
            version: version,
            region: region,
            in: database
        ) else {
            throw MapleStoryError.invalidWorld
        }
        guard world.isEnabled else {
            throw MapleStoryError.invalidWorld
        }
        guard let channel = try await Channel.fetch(channelIndex, world: world.id, in: database) else {
            throw MapleStoryError.invalidChannel
        }
        let characters = try await Character.fetch(
            user: user,
            world: world.id,
            in: database
        )
        // update client state
        state.channel = channel.id
        state.world = world.id
        return characters
    }
}
