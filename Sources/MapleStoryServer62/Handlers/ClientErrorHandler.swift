//
//  ClientError.swift
//
//
//  Created by Alsey Coleman Miller on 5/4/24.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles client error reports sent to the server.
///
/// # Client Error System
///
/// When the MapleStory client encounters an internal error during startup
/// or gameplay, it may send an error report to the server. This allows
/// server administrators to monitor and diagnose client-side issues.
///
/// # Error Reporting Flow
///
/// 1. Client encounters an internal error
/// 2. Client generates error code and description
/// 3. Client sends error report to server
/// 4. Server logs the error with client address
/// 5. Server may take action based on error severity
///
/// # Error Information
///
/// The error packet contains:
/// - **error code**: Numeric error identifier
/// - **client address**: IP address of the client
///
/// # Logging
///
/// Errors are logged using `NSLog` with format:
/// ```
/// Client start error [address]: error_code
/// ```
///
/// # Common Client Errors
///
/// Common error codes include:
/// - **Packet errors**: Invalid or malformed packets
/// - **Connection errors**: Failed to connect to server
/// - **Resource errors**: Missing or corrupt game files
/// - **Version errors**: Client/server version mismatch
/// - **Memory errors**: Out of memory or corruption
///
/// # Use Cases
///
/// Error logging helps with:
/// - **Debugging**: Identifying common client issues
/// - **Monitoring**: Tracking server health and client stability
/// - **Support**: Diagnosing player issues
/// - **Analytics**: Understanding error patterns
///
/// # Server Action
///
/// Currently, the handler only logs errors. Potential enhancements:
/// - Disconnect clients with critical errors
/// - Rate limit error reporting (prevent spam)
/// - Aggregate error statistics
/// - Alert administrators on critical errors
///
/// # Response
///
/// No response sent. The error is silently logged.
public struct ClientErrorHandler: PacketHandler {
    
    public typealias Packet = MapleStory62.ClientStartError
        
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let address = connection.address.address
        NSLog("Client start error [\(address)]: \(packet.error)")
    }
}
