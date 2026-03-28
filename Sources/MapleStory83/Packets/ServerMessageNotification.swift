//
//  ServerMessageNotification.swift
//

import Foundation

/// Server message / notice notification sent to client.
///
/// type: 0=[Notice], 1=Popup, 2=Megaphone, 3=Super Megaphone, 4=Scrolling ticker, 5=Pink text, 6=Lightblue text, 7=NPC broadcast
public struct ServerMessageNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .serverMessage }

    public let type: UInt8

    /// Only present when type == 4 (scrolling ticker).
    public let isScrolling: UInt8?

    public let message: String
}
