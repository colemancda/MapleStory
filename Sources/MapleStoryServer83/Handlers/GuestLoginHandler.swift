//
//  GuestLoginHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/26/24.
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct GuestLoginHandler: PacketHandler {
    
    public typealias Packet = MapleStory83.GuestLoginRequest
        
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let response = try await guestLogin(packet, connection: connection)
        try await connection.send(response)
    }
}

internal extension GuestLoginHandler {
    
    func guestLogin<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory83.GuestLoginRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory83.LoginResponse {
        do {
            let user = try await connection.guestLogin()
            let database = await connection.database
            let configuration = try await database.fetch(Configuration.self)
            return .success(.init(user: user, configuration: configuration))
        }
        catch MapleStoryError.login(let error) {
            return .failure(error)
        }
    }
}
