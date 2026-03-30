//
//  FacialExpressionNotification.swift
//

import Foundation

/// Facial expression broadcast to nearby players.
///
public struct FacialExpressionNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .facialExpression }

    public let characterID: UInt32

    public let expression: Int32

    public init(characterID: UInt32, expression: Int32) {
        self.characterID = characterID
        self.expression = expression
    }
}
