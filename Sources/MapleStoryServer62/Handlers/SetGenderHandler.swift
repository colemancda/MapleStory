//
//  SetGenderHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/29/24.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles gender selection for new accounts.
///
/// When a new account is created, players may be prompted to select their
/// gender. The gender affects the default character appearance options
/// available during character creation.
///
/// # Gender Selection
///
/// - **Male (0)**: Different hair, face, and clothing options
/// - **Female (1)**: Different hair, face, and clothing options
///
/// # When Gender is Set
///
/// Gender selection occurs:
/// - During new account creation flow
/// - After accepting the game license
/// - Before reaching the character selection screen
///
/// # Response
///
/// Sends `SetGenderResponse` confirming the gender was set.
/// The client then proceeds to the character selection screen.
public struct SetGenderHandler: PacketHandler {
    
    public typealias Packet = MapleStory62.SetGenderRequest
    
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
        _ request: MapleStory62.SetGenderRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory62.LoginResponse {
        let user = try await connection.setGender(
            request.gender,
            didConfirm: request.confirmed
        )
        return .success(username: user.username.rawValue)
    }
}
