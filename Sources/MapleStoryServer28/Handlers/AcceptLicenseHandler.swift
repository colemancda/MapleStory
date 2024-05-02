//
//  AcceptLicenseHandler.swift
//
//
//  Created by Alsey Coleman Miller on 5/2/24.
//

import Foundation
import CoreModel
import MapleStory28
import MapleStoryServer

public struct AcceptLicenseHandler: PacketHandler {
    
    public typealias Packet = MapleStory28.AcceptLicenseRequest
        
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let response = try await acceptLicense(packet, connection: connection)
        try await connection.send(response)
    }
}

internal extension AcceptLicenseHandler {
    
    func acceptLicense<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory28.AcceptLicenseRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory28.LoginResponse {
        let user = try await connection.acceptLicense()
        return .success(.init(user: user))
    }
}
