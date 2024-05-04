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
            
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: MapleStory28.LoginRequest,
        connection: MapleStoryServer<Socket, Database, MapleStory28.ClientOpcode, MapleStory28.ServerOpcode>.Connection
    ) async throws {
        try await connection.login(packet)
    }
}

extension MapleStoryServer.Connection where ClientOpcode == MapleStory28.ClientOpcode, ServerOpcode == MapleStory28.ServerOpcode {
    
    func login(
        _ packet: MapleStory28.LoginRequest
    ) async throws {
        let response = try await loginResponse(packet)
        try await send(response)
    }
    
    func loginResponse(
        _ request: MapleStory28.LoginRequest
    ) async throws -> MapleStory28.LoginResponse {
        do {
            // update database
            let user = try await self.login(
                username: request.username,
                password: request.password
            )
            return .success(.init(user: user))
        }
        catch MapleStoryError.login(let error) {
            return .failure(error)
        }
    }
}
