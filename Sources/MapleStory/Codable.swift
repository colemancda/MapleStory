//
//  Codable.swift
//  
//
//  Created by Alsey Coleman Miller on 12/14/22.
//

import Foundation

// MARK: - MapleStoryCodable

/// MapleStory Codable
public typealias MapleStoryCodable = MapleStoryEncodable & MapleStoryDecodable

/// MapleStory Decodable type
public protocol MapleStoryDecodable: Decodable {
    
    init(from container: MapleStoryDecodingContainer) throws
}

/// MapleStory Encodable type
public protocol MapleStoryEncodable: Encodable {
    
    func encode(to container: MapleStoryEncodingContainer) throws
}
