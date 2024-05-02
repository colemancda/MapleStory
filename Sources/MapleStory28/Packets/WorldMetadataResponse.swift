//
//  WorldMetadataResponse.swift
//
//
//  Created by Alsey Coleman Miller on 5/2/24.
//

import Foundation
import MapleStory

public struct WorldMetadataResponse: MapleStoryPacket, Equatable, Hashable, Codable, Sendable {
    
    public static var opcode: ServerOpcode { .loginWorldMeta }
    
    public let warning: Channel.Status
    
    public let population: Channel.Status
    
    public init(
        warning: Channel.Status = .normal,
        population: Channel.Status = .normal
    ) {
        self.warning = warning
        self.population = population
    }
}
