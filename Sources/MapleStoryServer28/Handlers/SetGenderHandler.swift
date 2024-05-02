//
//  SetGenderHandler.swift
//
//
//  Created by Alsey Coleman Miller on 5/2/24.
//

import Foundation
import CoreModel
import MapleStory28
import MapleStoryServer

public struct SetGenderHandler: PacketHandler {
    
    public typealias Packet = MapleStory28.SetGenderRequest
    
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let response = try await setGender(packet, connection: connection)
        try await connection.send(response)
    }
}

internal extension SetGenderHandler {
    
    func setGender<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory28.SetGenderRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory28.LoginResponse {
        let user = try await connection.setGender(
            request.gender,
            didConfirm: request.confirmed
        )
        return .success(.init(user: user))
    }
}
