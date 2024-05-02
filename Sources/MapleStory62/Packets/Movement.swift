//
//  Movement.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public enum Movement: Codable, Equatable, Hashable, Sendable {
    
    case absolute(Absolute)
    case relative(Relative)
    case teleport(Teleport)
    case changeEquipment(ChangeEquipment)
    case chair(Chair)
    case jumpDown(JumpDown)
}

extension Movement: MapleStoryCodable {
    
    public init(from container: MapleStoryDecodingContainer) throws {
        let command = container.peek()
        switch command {
        case 0, 5, 17:
            let value = try container.decode(Absolute.self, forKey: CodingKeys.absolute)
            self = .absolute(value)
        case 1, 2, 6, 12, 13, 16:
            let value = try container.decode(Relative.self, forKey: CodingKeys.relative)
            self = .relative(value)
        case 3, 4, 7, 8, 9, 14:
            let value = try container.decode(Teleport.self, forKey: CodingKeys.teleport)
            self = .teleport(value)
        case 10:
            let value = try container.decode(ChangeEquipment.self, forKey: CodingKeys.changeEquipment)
            self = .changeEquipment(value)
        case 11:
            let value = try container.decode(Chair.self, forKey: CodingKeys.chair)
            self = .chair(value)
        case 15:
            let value = try container.decode(JumpDown.self, forKey: CodingKeys.jumpDown)
            self = .jumpDown(value)
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Invalid command \(command)"))
        }
    }
    
    public func encode(to container: MapleStoryEncodingContainer) throws {
        switch self {
        case .absolute(let absolute):
            try container.encode(absolute, forKey: CodingKeys.absolute)
        case .relative(let relative):
            try container.encode(relative, forKey: CodingKeys.relative)
        case .teleport(let teleport):
            try container.encode(teleport, forKey: CodingKeys.teleport)
        case .changeEquipment(let changeEquipment):
            try container.encode(changeEquipment, forKey: CodingKeys.changeEquipment)
        case .chair(let chair):
            try container.encode(chair, forKey: CodingKeys.chair)
        case .jumpDown(let jumpDown):
            try container.encode(jumpDown, forKey: CodingKeys.jumpDown)
        }
    }
}

// MARK: - Supporting Types

public extension Movement {
    
    struct Absolute: Codable, Equatable, Hashable, Sendable {
        
        public let command: UInt8
        
        public var xpos: UInt16
        
        public var ypos: UInt16
        
        public var xwobble: UInt16
        
        public var ywobble: UInt16
        
        internal let value0: UInt16
        
        public var newState: UInt8
        
        public var duration: UInt16
    }
    
    struct Relative: Codable, Equatable, Hashable, Sendable {
        
        public let command: UInt8
        
        public var xmod: UInt16
        
        public var ymod: UInt16
        
        public var newState: UInt8
        
        public var duration: UInt16
    }
    
    struct Teleport: Codable, Equatable, Hashable, Sendable {
        
        public let command: UInt8
        
        public var xpos: UInt16
        
        public var ypos: UInt16
        
        public var xwobble: UInt16
        
        public var ywobble: UInt16
        
        public var newState: UInt8
    }
    
    struct ChangeEquipment: Codable, Equatable, Hashable, Sendable {
        
        public let command: UInt8
        
        public var wui: UInt8
    }
    
    struct Chair: Codable, Equatable, Hashable, Sendable {
        
        public let command: UInt8
        
        public var xpos: UInt16
        
        public var ypos: UInt16
        
        internal let value0: UInt16
        
        public var newState: UInt8
        
        public var duration: UInt16
    }
    
    struct JumpDown: Codable, Equatable, Hashable, Sendable {
        
        public let command: UInt8
        
        public var xpos: UInt16
        
        public var ypos: UInt16
        
        public var xwobble: UInt16
        
        public var ywobble: UInt16
        
        internal let value0: UInt16
        
        public var fh: UInt16
        
        public var newState: UInt8
        
        public var duration: UInt16
    }
}
