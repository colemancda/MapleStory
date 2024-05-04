//
//  ServerMessageNotification.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public enum ServerMessageNotification: MapleStoryPacket, Codable, Equatable, Hashable {
    
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
        case .notice:
            return .notice
        case .popup:
            return .popup
        case .megaphone:
            return .megaphone
        case .superMegaphone:
            return .superMegaphone
        case .topScrolling:
            return .topScrolling
        case .pinkText:
            return .pinkText
        case .lightBlueText:
            return .lightBlueText
        }
    }
    
    var message: String {
        switch self {
        case .notice(let message):
            return message
        case .popup(let message):
            return message
        case .megaphone(let message):
            return message
        case .superMegaphone(let message, _, _):
            return message
        case .topScrolling(let message):
            return message
        case .pinkText(let message):
            return message
        case .lightBlueText(let message):
            return message
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
            let message = try container.decode(String.self, forKey: MapleStoryCodingKeys.message)
            self = .notice(message: message)
        case .popup:
            let message = try container.decode(String.self, forKey: MapleStoryCodingKeys.message)
            self = .popup(message: message)
        case .megaphone:
            let message = try container.decode(String.self, forKey: MapleStoryCodingKeys.message)
            self = .megaphone(message: message)
        case .superMegaphone:
            let message = try container.decode(String.self, forKey: MapleStoryCodingKeys.message)
            let channel = try container.decode(UInt8.self, forKey: MapleStoryCodingKeys.channel)
            let megaEarphone = try container.decode(Bool.self, forKey: MapleStoryCodingKeys.megaEarphone)
            self = .superMegaphone(message: message, channel: channel, megaEarphone: megaEarphone)
        case .topScrolling:
            let _ = try container.decode(Bool.self, forKey: MapleStoryCodingKeys.isServerMessage)
            let message = try container.decode(String.self, forKey: MapleStoryCodingKeys.message)
            self = .topScrolling(message: message)
        case .pinkText:
            let message = try container.decode(String.self, forKey: MapleStoryCodingKeys.message)
            self = .pinkText(message: message)
        case .lightBlueText:
            let message = try container.decode(String.self, forKey: MapleStoryCodingKeys.message)
            self = .lightBlueText(message: message)
        }
    }
    
    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(type, forKey: MapleStoryCodingKeys.type)
        switch self {
        case .notice:
            try container.encode(message, forKey: MapleStoryCodingKeys.message)
        case .popup:
            try container.encode(message, forKey: MapleStoryCodingKeys.message)
        case .megaphone:
            try container.encode(message, forKey: MapleStoryCodingKeys.message)
        case .superMegaphone(_, let channel, let megaEarphone):
            try container.encode(message, forKey: MapleStoryCodingKeys.message)
            try container.encode(channel, forKey: MapleStoryCodingKeys.channel)
            try container.encode(megaEarphone, forKey: MapleStoryCodingKeys.megaEarphone)
        case .topScrolling:
            try container.encode(true, forKey: MapleStoryCodingKeys.isServerMessage)
            try container.encode(message, forKey: MapleStoryCodingKeys.message)
        case .pinkText:
            try container.encode(message, forKey: MapleStoryCodingKeys.message)
        case .lightBlueText:
            try container.encode(message, forKey: MapleStoryCodingKeys.message)
        }
    }
}
