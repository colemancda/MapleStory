//
//  LoginHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/26/24.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

public struct LoginHandler: PacketHandler {
    
    public typealias Packet = MapleStory62.LoginRequest
        
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
        _ request: MapleStory62.LoginRequest,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws -> MapleStory62.LoginResponse {
        do {
            let user = try await connection.login(
                username: request.username,
                password: request.password
            )
            return .success(username: request.username)
        }
        catch let loginError as LoginError {
            return .failure(reason: loginError)
        }
    }
}
