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

public extension MapleStoryServer {
    
    struct GuestLoginHandler: PacketHandler {
                
        public let connection: MapleStoryServer<Socket, Storage>.Connection
        
        public init(connection: MapleStoryServer<Socket, Storage>.Connection) {
            self.connection = connection
        }
        
        public func handle(packet request: MapleStory62.GuestLoginRequest) async throws {
            let response = try await guestLogin(request)
            try await connection.respond(response)
        }
    }
}

internal extension MapleStoryServer.GuestLoginHandler {
    
    func guestLogin(
        _ request: MapleStory62.GuestLoginRequest
    ) async throws -> MapleStory62.LoginResponse {
        let user = try await connection.guestLogin()
        return .success(username: user.username.rawValue)
    }
}
