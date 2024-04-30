//
//  SetGenderHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/29/24.
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct SetGenderHandler: PacketHandler {
    
    public typealias Packet = MapleStory83.SetGenderRequest
    
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws {
        let response = try await setGender(packet, connection: connection)
        try await connection.respond(response)
    }
}

internal extension SetGenderHandler {
    
    func setGender<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory83.SetGenderRequest,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws -> MapleStory83.LoginResponse {
        let user = try await connection.setGender(request.gender, didConfirm: request.confirmed)
        return .success(LoginResponse.Success(user: user))
    }
}
