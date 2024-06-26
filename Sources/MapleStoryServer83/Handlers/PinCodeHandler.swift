//
//  PinCodeHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/29/24.
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct PinCodeHandler: PacketHandler {
    
    public typealias Packet = MapleStory83.PinOperationRequest
    
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
        _ request: MapleStory83.PinOperationRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory83.PinOperationResponse {
        let status = try await connection.pinCodeStatus(request.pinCode)
        return .init(status: status)
    }
}
