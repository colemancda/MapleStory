//
//  DamageReactorRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct DamageReactorRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .damageReactor }

    public let objectID: UInt32

    public let characterPosition: UInt32

    public let stance: Int16
}
