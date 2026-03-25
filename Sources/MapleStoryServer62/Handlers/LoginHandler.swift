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

/// Handles player login requests with username and password authentication.
///
/// # Login Flow
///
/// 1. Player sends username and password
/// 2. Server validates credentials
/// 3. Server checks for:
///    - Valid username/password
///    - Account not banned
///    - IP not banned
///    - MAC address not banned
///    - Account not temporarily banned
/// 4. On success: Server registers client connection
/// 5. On failure: Server returns error code
///
/// # Login Response Codes
///
/// | Code | Meaning |
/// |------|---------|
/// | 0 | Success |
/// | 3 | Banned (IP/MAC) |
/// | 5 | Incorrect password |
/// | 7 | Account not registered |
/// | 10+ | Various error conditions |
///
/// # Auto-Registration
///
/// If enabled, creates new account when username doesn't exist.
/// Only works if IP/MAC are not banned.
///
/// # GM Registration
///
/// GM accounts are registered separately from regular accounts.
public struct LoginHandler: PacketHandler {

    public typealias Packet = MapleStory62.LoginRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let response = try await login(packet, connection: connection)
        try await connection.send(response)
    }
}

internal extension LoginHandler {

    func login<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory62.LoginRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory62.LoginResponse {
        do {
            let _ = try await connection.login(
                username: request.username,
                password: request.password
            )
            return .success(username: request.username)
        }
        catch MapleStoryError.login(let error) {
            return .failure(reason: error)
        }
    }
}
