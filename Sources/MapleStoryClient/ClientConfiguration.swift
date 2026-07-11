//
//  ClientConfiguration.swift
//  MapleStoryClient
//

import Foundation
import MapleStory

/// Configuration for a ``MapleStoryClient`` connection.
public struct ClientConfiguration: Equatable, Hashable, Sendable {

    /// Local address to bind the client socket to before connecting.
    ///
    /// Defaults to an ephemeral port on all interfaces.
    public var address: MapleStoryAddress

    /// The remote server address to connect to.
    public var destination: MapleStoryAddress

    /// Symmetric key used for AES packet encryption, or `nil` to disable it.
    public var key: Key?

    public init(
        address: MapleStoryAddress = ClientConfiguration.defaultLocalAddress,
        destination: MapleStoryAddress,
        key: Key? = .default
    ) {
        self.address = address
        self.destination = destination
        self.key = key
    }
}

public extension ClientConfiguration {

    /// Binds to an ephemeral local port on all interfaces.
    static var defaultLocalAddress: MapleStoryAddress {
        MapleStoryAddress(address: "0.0.0.0", port: 0)!
    }
}
