//
//  CreateCharacterRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation
import MapleStory

public struct CreateCharacterRequest: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x16 }
    
    public let name: String
    
    public let face: UInt32
    
    public let hair: UInt32
    
    public let hairColor: UInt32
    
    public let skinColor: UInt32
    
    public let top: UInt32
    
    public let bottom: UInt32
    
    public let shoes: UInt32
    
    public let weapon: UInt32
    
    public let gender: Gender
    
    public let str: UInt8
    
    public let dex: UInt8
    
    public let int: UInt8
    
    public let luk: UInt8
}

public extension Character {
    
    init?(
        id: Character.ID,
        request: CreateCharacterRequest
    ) {
        guard let name = CharacterName(rawValue: request.name),
              request.skinColor <= UInt8.max,
              let skinColor = SkinColor(rawValue: UInt8(request.skinColor)) else {
            return nil
        }
        self.init(
            id: id,
            created: Date(),
            name: name,
            gender: request.gender,
            skinColor: skinColor,
            face: request.face,
            hair: request.hair,
            hairColor: request.hairColor,
            str: numericCast(request.str),
            dex: numericCast(request.dex),
            int: numericCast(request.int),
            luk: numericCast(request.luk)
        )
    }
}
