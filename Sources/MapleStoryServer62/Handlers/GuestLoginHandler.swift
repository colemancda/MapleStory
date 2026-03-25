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

/// Handles guest login requests (login without an account).
///
/// Guest login allows players to try the game without registering an account.
/// Guest accounts have limited functionality compared to full accounts.
///
/// # Guest Login Flow
///
/// 1. Player clicks "Guest Login" on the login screen
/// 2. Client sends guest login request
/// 3. Server creates a temporary guest session
/// 4. Server returns login success response
/// 5. Player can play with limited access
///
/// # Guest Limitations
///
/// Guest accounts typically cannot:
/// - Save progress between sessions
/// - Use the buddy list
/// - Join guilds
/// - Use the auction house/trading system
///
/// # Response
///
/// Sends `LoginResponse` with:
/// - Success: Contains username for the guest session
/// - Failure: Contains the login error reason
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
