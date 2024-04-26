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

public extension MapleStoryServer {
    
    struct LoginHandler: PacketHandler {
                
        public let connection: MapleStoryServer<Socket, Storage>.Connection
        
        public init(connection: MapleStoryServer<Socket, Storage>.Connection) {
            self.connection = connection
        }
        
        public func handle(packet request: MapleStory62.LoginRequest) async throws {
            let response = try await login(request)
            try await connection.respond(response)
        }
    }
}

internal extension MapleStoryServer.LoginHandler {
    
    func login(
        _ request: MapleStory62.LoginRequest
    ) async throws -> MapleStory62.LoginResponse {
        do {
            // update database
            try await connection.login(
                username: request.username,
                password: request.password,
                autoregister: true // TODO: Add server configuration
            )
            return .success(username: request.username)
        }
        catch let loginError as LoginError {
            // TODO: handle failures
            return .success(username: request.username)
        }
    }
}
