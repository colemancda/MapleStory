//
//  LoginHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/26/24.
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct LoginHandler: PacketHandler {
    
    public typealias Packet = MapleStory83.LoginRequest
        
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws {
        let response = try await login(packet, connection: connection)
        try await connection.respond(response)
    }
}

internal extension LoginHandler {
    
    func login<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory83.LoginRequest,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws -> MapleStory83.LoginResponse {
        do {
            // update database
            let user = try await connection.login(
                username: request.username,
                password: request.password,
                autoregister: true // TODO: Add server configuration
            )
            return .success(.init(user: user))
        }
        catch let loginError as LoginError {
            // TODO: handle failures
            return .failure(loginError)
        }
    }
}
