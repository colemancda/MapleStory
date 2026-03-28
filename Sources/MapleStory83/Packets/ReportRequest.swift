//
//  ReportRequest.swift
//

import Foundation

public struct ReportRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .report }

    public init() { }
}
