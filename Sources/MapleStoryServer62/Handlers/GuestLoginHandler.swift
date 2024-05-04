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
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let response = try await guestLogin(packet, connection: connection)
        try await connection.send(response)
        // send other data
        //try await connection.send(GuestLoginResponse())
        //try await Task.sleep(for: .seconds(3))
        //try await connection.send(ServerStatusResponse(.normal))
    }
}

internal extension GuestLoginHandler {
    
    func guestLogin<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory62.GuestLoginRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory62.LoginResponse {
        do {
            let user = try await connection.guestLogin()
            return .success(username: user.username.rawValue)
        }
        catch MapleStoryError.login(let error) {
            return .failure(reason: error)
        }
    }
}
