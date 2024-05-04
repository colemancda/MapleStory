//
//  SessionEncryptionHandler.swift
//
//
//  Created by Alsey Coleman Miller on 5/3/24.
//

import Foundation
import MapleStory28
import MapleStoryServer
import CoreModel

public struct SessionEncryptionHandler <Socket: MapleStorySocket, Database: ModelStorage>: ServerHandler {
    
    public typealias Connection = MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    
    public let world: World.ID
    
    public init(world: World.ID) {
        self.world = world
    }
    
    public func didConnect(
        connection: Connection
    ) async {
        // fetch sessions from IP address
        do {
            let database = await connection.database
            let address = connection.address.address
            guard let world = try await database.fetch(World.self, for: self.world) else {
                throw MapleStoryError.invalidWorld
            }
            // no session from IP address
            guard let session = try await Session.fetch(address: address, channels: world.channels, in: database) else {
                throw MapleStoryError.notAuthenticated
            }
            // set nonce
            await connection.setNonce(send: session.sendNonce, recieve: session.recieveNonce)
        } catch {
            await connection.close(error)
        }
    }
    
    public func didDisconnect(address: MapleStoryAddress) async {
        
    }
}
