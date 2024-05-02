//
//  LoginHandler.swift
//  
//
//  Created by Alsey Coleman Miller on 5/1/24.
//

import Foundation
import MapleStory28
import MapleStoryServer
import CoreModel

public struct LoginHandler: PacketHandler {
    
    public typealias Packet = MapleStory28.LoginRequest
        
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
        _ request: MapleStory28.LoginRequest,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws -> MapleStory28.LoginResponse {
        do {
            // update database
            let user = try await connection.login(
                username: request.username,
                password: request.password
            )
            let configuration = try await connection.database.fetch(Configuration.self)
            return .success(.init(user: user))
        }
        catch let loginError as LoginError {
            return .failure(loginError)
        }
    }
}

