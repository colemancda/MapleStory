//
//  MapleStoryServerConfiguration.swift
//
//
//  Created by Alsey Coleman Miller on 4/25/24.
//

import Foundation

/// Server Configuration
public struct ServerConfiguration: Equatable, Hashable, Sendable {
    
    public let address: MapleStoryAddress
    
    public let backlog: Int
    
    public let version: Version
    
    public let region: Region
    
    public let key: Key
    
    public init(
        address: MapleStoryAddress = .loginServerDefault,
        backlog: Int = 1000,
        version: Version,
        region: Region = .global,
        key: Key = .default
    ) {
        self.address = address
        self.backlog = backlog
        self.version = version
        self.region = region
        self.key = key
    }
}
