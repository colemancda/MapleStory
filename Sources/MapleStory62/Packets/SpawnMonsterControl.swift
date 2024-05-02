//
//  SpawnMonsterControl.swift
//  
//
//  Created by Alsey Coleman Miller on 12/23/22.
//

import Foundation

public struct SpawnMonsterControl: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ServerOpcode { .spawnMonsterControl }
    
    
}
