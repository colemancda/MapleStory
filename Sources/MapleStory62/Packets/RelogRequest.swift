//
//  RelogRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/23/26.
//

import Foundation
import MapleStory

public struct RelogRequest: MapleStoryPacket, Equatable, Hashable, Codable, Sendable {

    public static var opcode: ClientOpcode { .relog }

    public init() { }
}
