//
//  PinCodeHandler.swift
//
//
//  Created by Alsey Coleman Miller on 5/2/24.
//

import Foundation
import CoreModel
import MapleStory28
import MapleStoryServer

public struct PinCodeHandler: PacketHandler {
    
    public typealias Packet = MapleStory28.PinOperationRequest
    
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet request: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let status = try await connection.pinCodeStatus(request.pinCode)
        // return pin code error
        guard status == .success else {
            let response = PinOperationResponse(status: status)
            try await connection.send(response)
            return
        }
        // update IP address
        guard var user = try await connection.user else {
            throw MapleStoryError.notAuthenticated
        }
        user.ipAddress = connection.address.address
        // return worlds
        let maxNumberOfWorlds = 14
        let responses: [ServerListResponse] = try await connection
            .listWorlds()
            .prefix(maxNumberOfWorlds)
            .map { .world($0.world, channels: $0.channels) } 
            + [.end]
        // send list
        for response in responses {
            try await connection.send(response)
        }
    }
}
