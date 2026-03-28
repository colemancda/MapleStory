//
//  GeneralChatRequest.swift
//

import Foundation

public struct GeneralChatRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .generalChat }

    public let message: String

    public let show: Bool
}
