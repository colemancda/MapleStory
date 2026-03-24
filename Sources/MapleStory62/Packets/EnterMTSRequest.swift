//
//  EnterMTSRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct EnterMTSRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .enterMTS }

    public init() { }
}
