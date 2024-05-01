//
//  CreateCharacterRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import MapleStory

public struct CreateCharacterRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: Opcode { .init(client: .createCharacter) }
    
    public let name: String
    
    public let job: Job
    
    public let face: UInt32
    
    public let hair: UInt32
    
    public let hairColor: UInt32
    
    public let skinColor: UInt32
    
    public let top: UInt32
    
    public let bottom: UInt32
    
    public let shoes: UInt32
    
    public let weapon: UInt32
    
    public let gender: Gender
}

// MARK: - Supporting Types

public extension CreateCharacterRequest {
    
    enum Job: UInt32, Codable, CaseIterable, Sendable {
        
        /// Knights of Cygnus
        case knights        = 0
        
        /// Adventurer / Explorer
        case adventurer     = 1
        
        /// Aran / Legend
        case legend         = 2
    }
}

public extension Job {
    
    init(initial: CreateCharacterRequest.Job) {
        switch initial {
        case .adventurer:
            self = .beginner
        case .knights:
            self = .noblesse
        case .legend:
            self = .legend
        }
    }
}
