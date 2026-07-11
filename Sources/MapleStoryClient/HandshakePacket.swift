//
//  HandshakePacket.swift
//  MapleStoryClient
//
//  Ported from the `Net` layer of https://github.com/ryantpayton/MapleStory-Client
//

import Foundation
import MapleStory

/// A version-agnostic view of the initial handshake ("Hello") packet a MapleStory
/// server sends immediately after a client connects.
///
/// The server transmits this packet unencrypted. It carries the protocol version,
/// the region/locale, and the two initialization vectors used to seed the send and
/// receive ciphers. Concrete per-version packets (e.g. `MapleStory83.HelloPacket`)
/// conform to this protocol so `MapleStoryClient` can complete the handshake without
/// knowing the specific version layout.
public protocol HandshakePacket: Decodable, Sendable {

    /// Protocol version advertised by the server.
    var version: Version { get }

    /// Region / locale of the server.
    var region: Region { get }

    /// Nonce the server uses to encrypt the packets it sends.
    ///
    /// From the client's perspective this seeds the *receive* cipher.
    var sendNonce: Nonce { get }

    /// Nonce the server uses to decrypt the packets it receives.
    ///
    /// From the client's perspective this seeds the *send* cipher.
    var recieveNonce: Nonce { get }
}
