//
//  FacialExpressionNotification.swift
//
//

import Foundation

public struct FacialExpressionNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .facialExpression }

    public init() { }
}

