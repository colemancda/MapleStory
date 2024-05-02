//
//  AcceptLicenseHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/29/24.
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct AcceptLicenseHandler: PacketHandler {
    
    public typealias Packet = MapleStory83.AcceptLicenseRequest
        
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
        _ request: MapleStory83.AcceptLicenseRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory83.LoginResponse {
        let user = try await connection.acceptLicense()
        let configuration = try await connection.database.fetch(Configuration.self)
        return .success(.init(user: user, configuration: configuration))
    }
}
