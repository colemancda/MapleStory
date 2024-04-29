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

public struct PinCodeHandler: PacketHandler {
    
    public typealias Packet = MapleStory62.PinOperationRequest
    
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws {
        let response = try await pinOperation(packet, connection: connection)
        try await connection.respond(response)
    }
}

internal extension PinCodeHandler {
    
    func pinOperation<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory62.PinOperationRequest,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws -> MapleStory62.PinOperationResponse {
        //log("Check Pin - \(username)")
        return .success
    }
}
