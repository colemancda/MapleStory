//
//  ServerMessageNotification.swift
//

import Foundation
import MapleStory

public enum ServerMessageNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .serverMessage }

    case notice(message: String)
    case popup(message: String)
    case megaphone(message: String)
    case superMegaphone(message: String, channel: UInt8, megaEarphone: Bool)
    case topScrolling(message: String)
    case pinkText(message: String)
    case lightBlueText(message: String)
}

public extension ServerMessageNotification {

    var type: ServerMessageType {
        switch self {
        case .notice:          return .notice
        case .popup:           return .popup
        case .megaphone:       return .megaphone
        case .superMegaphone:  return .superMegaphone
        case .topScrolling:    return .topScrolling
        case .pinkText:        return .pinkText
        case .lightBlueText:   return .lightBlueText
        }
    }

    var message: String {
        switch self {
        case .notice(let m):              return m
        case .popup(let m):               return m
        case .megaphone(let m):           return m
        case .superMegaphone(let m, _, _): return m
        case .topScrolling(let m):        return m
        case .pinkText(let m):            return m
        case .lightBlueText(let m):       return m
        }
    }
}

extension ServerMessageNotification: MapleStoryCodable {

    enum MapleStoryCodingKeys: String, CodingKey {
        case type
        case message
        case isServerMessage
        case channel
        case megaEarphone
    }

    public init(from container: MapleStoryDecodingContainer) throws {
        let type = try container.decode(ServerMessageType.self, forKey: MapleStoryCodingKeys.type)
        switch type {
        case .notice:
            self = .notice(message: try container.decode(String.self, forKey: MapleStoryCodingKeys.message))
        case .popup:
            self = .popup(message: try container.decode(String.self, forKey: MapleStoryCodingKeys.message))
        case .megaphone:
            self = .megaphone(message: try container.decode(String.self, forKey: MapleStoryCodingKeys.message))
        case .superMegaphone:
            let message = try container.decode(String.self, forKey: MapleStoryCodingKeys.message)
            let channel = try container.decode(UInt8.self, forKey: MapleStoryCodingKeys.channel)
            let megaEarphone = try container.decode(Bool.self, forKey: MapleStoryCodingKeys.megaEarphone)
            self = .superMegaphone(message: message, channel: channel, megaEarphone: megaEarphone)
        case .topScrolling:
            let _ = try container.decode(Bool.self, forKey: MapleStoryCodingKeys.isServerMessage)
            self = .topScrolling(message: try container.decode(String.self, forKey: MapleStoryCodingKeys.message))
        case .pinkText:
            self = .pinkText(message: try container.decode(String.self, forKey: MapleStoryCodingKeys.message))
        case .lightBlueText:
            self = .lightBlueText(message: try container.decode(String.self, forKey: MapleStoryCodingKeys.message))
        }
    }

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(type, forKey: MapleStoryCodingKeys.type)
        switch self {
        case .superMegaphone(_, let channel, let megaEarphone):
            try container.encode(message, forKey: MapleStoryCodingKeys.message)
            try container.encode(channel, forKey: MapleStoryCodingKeys.channel)
            try container.encode(megaEarphone, forKey: MapleStoryCodingKeys.megaEarphone)
        case .topScrolling:
            try container.encode(true, forKey: MapleStoryCodingKeys.isServerMessage)
            try container.encode(message, forKey: MapleStoryCodingKeys.message)
        default:
            try container.encode(message, forKey: MapleStoryCodingKeys.message)
        }
    }
}
