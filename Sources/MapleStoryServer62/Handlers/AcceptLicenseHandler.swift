//
//  AcceptLicenseHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/29/24.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

public struct AcceptLicenseHandler: PacketHandler {
    
    public typealias Packet = MapleStory62.AcceptLicenseRequest
        
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws {
        let response = try await acceptLicense(packet, connection: connection)
        try await connection.respond(response)
    }
}

internal extension AcceptLicenseHandler {
    
    func acceptLicense<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory62.AcceptLicenseRequest,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws -> MapleStory62.LoginResponse {
        let user = try await connection.acceptLicense()
        return .success(username: user.username.rawValue)
    }
}
