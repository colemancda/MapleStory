//
//  ClientHandler.swift
//  MapleStoryClient
//

import Foundation
import MapleStory

/// Handles a decoded server packet, with access to the client session so it can
/// send responses.
///
/// The client-side analogue of the server's `ServerHandler`.
public protocol ClientHandler: Sendable {

    /// The concrete ``MapleStoryClient`` this handler operates on.
    associatedtype Client

    /// The server packet this handler responds to.
    associatedtype Packet: MapleStoryPacket & Decodable & Sendable

    func handle(packet: Packet, client: Client) async throws
}
