//
//  PinCodeHandler.swift
//  
//
//  Created by Alsey Coleman Miller on 4/28/24.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles PIN code verification during login.
///
/// The PIN code is a secondary security layer (4-6 digit code) that players
/// must enter after logging in with their password. It provides additional
/// account security against unauthorized access.
///
/// # PIN Code Flow
///
/// 1. Player successfully logs in with username/password
/// 2. Server prompts for PIN code
/// 3. Player enters their PIN
/// 4. Client sends PIN operation request
/// 5. Server validates PIN
/// 6. If correct → proceed to character selection
/// 7. If incorrect → show error, player can retry
///
/// # PIN Operations
///
/// - **Enter PIN**: Regular login PIN verification
/// - **Register PIN**: First-time PIN setup
/// - **Change PIN**: Update existing PIN
///
/// # Current Implementation
///
/// PIN validation always returns success (PIN check is bypassed).
/// A full implementation would validate against stored PIN hash.
///
/// # Response
///
/// Returns `PinOperationResponse` with `.success` or `.failure`.
public struct PinCodeHandler: PacketHandler {
    
    public typealias Packet = MapleStory62.PinOperationRequest
    
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let response = try await pinOperation(packet, connection: connection)
        try await connection.send(response)
    }
}

internal extension PinCodeHandler {
    
    func pinOperation<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory62.PinOperationRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory62.PinOperationResponse {
        //log("Check Pin - \(username)")
        return .success
    }
}
