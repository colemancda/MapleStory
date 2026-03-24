//
//  FaceExpressionRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct FaceExpressionRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .faceExpression }

    /// Expression / emote ID
    public let emote: UInt32
}
