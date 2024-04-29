//
//  GuestLoginHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/26/24.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

public struct GuestLoginHandler: PacketHandler {
    
    public typealias Packet = MapleStory62.GuestLoginRequest
        
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws {
        let response = try await guestLogin(packet, connection: connection)
        try await connection.respond(response)
    }
}

internal extension GuestLoginHandler {
    
    func guestLogin<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory62.GuestLoginRequest,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws -> MapleStory62.LoginResponse {
        let user = try await connection.guestLogin()
        return .success(username: user.username.rawValue)
    }
}