//
//  CancelDebuffRequest.swift
//

import Foundation

public struct CancelDebuffRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .cancelDebuff }

    public init() { }
}
