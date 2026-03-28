//
//  FaceExpressionRequest.swift
//

import Foundation

public struct FaceExpressionRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .faceExpression }

    public let expression: UInt32
}
