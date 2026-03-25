//
//  FacialExpressionNotification.swift
//
//

import Foundation

public struct FacialExpressionNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .facialExpression }

    public let characterID: UInt32

    public let expression: UInt32

    public init(characterID: UInt32, expression: UInt32) {
        self.characterID = characterID
        self.expression = expression
    }
}

extension FacialExpressionNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(characterID, isLittleEndian: true)
        try container.encode(expression, isLittleEndian: true)
    }
}
