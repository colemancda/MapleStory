//
//  StrangeDataHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/23/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles "strange data" / client error reports.
///
/// This packet is sent by the client when it encounters unusual data or
/// internal errors during gameplay. It provides diagnostic information
/// to help identify and fix client-side issues.
///
/// # Error Information
///
/// The packet contains:
/// - **error**: Error code identifying the type of issue
/// - **value0**: Additional diagnostic value
/// - **value1**: Additional diagnostic value
///
/// # Logging
///
/// Errors are logged using `NSLog` with format:
/// ```
/// Strange data from [address]: error=X v0=Y v1=Z
/// ```
///
/// # Response
///
/// No response is sent. The error is silently logged for diagnostics.
///
/// # Related Handlers
///
/// - `ClientErrorHandler`: Handles client startup errors
/// - `StrangeDataHandler`: Handles runtime strange data errors
public struct StrangeDataHandler: PacketHandler {

    public typealias Packet = MapleStory62.ClientErrorRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // No response; log for diagnostics
        NSLog("Strange data from \(connection.address): error=\(packet.error) v0=\(packet.value0) v1=\(packet.value1)")
    }
}
