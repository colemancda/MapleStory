//
//  EnterCashShopRequest.swift
//

import Foundation

public struct EnterCashShopRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .enterCashshop }

    public init() { }
}
