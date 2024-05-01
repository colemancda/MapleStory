//
//  SetGenderRequest.swift
//
//
//  Created by Alsey Coleman Miller on 4/29/24.
//

import Foundation
import MapleStory

public struct SetGenderRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: Opcode { .init(client: .setGender) }
    
    public var confirmed: Bool
    
    public var gender: Gender
    
    public init(
        confirmed: Bool = true,
        gender: Gender
    ) {
        self.confirmed = confirmed
        self.gender = gender
    }
}
