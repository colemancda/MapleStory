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

/// Handles acceptance of the MapleStory license agreement.
///
/// # License Acceptance Flow
///
/// 1. Client sends license acceptance request
/// 2. Server validates session state
/// 3. Server accepts license on user account
/// 4. Server returns success with username
///
/// # Purpose
///
/// This handler is used when players first start the game and need to accept
/// the terms of service/license agreement. After accepting, the license is marked
/// as accepted on the user account, so players don't need to accept it again.
///
/// # Response
///
/// On successful acceptance, returns login success with the username.
public struct AcceptLicenseHandler: PacketHandler {
    
    public typealias Packet = MapleStory62.AcceptLicenseRequest
        
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
        _ request: MapleStory62.AcceptLicenseRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory62.LoginResponse {
        let user = try await connection.acceptLicense()
        return .success(username: user.username.rawValue)
    }
}
