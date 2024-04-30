//
//  NPCTalkNotification.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public enum NPCTalkNotification: MapleStoryPacket, Equatable, Hashable {
    
    public static var opcode: Opcode { 0xED }
    
    case dialog(npc: UInt32, message: String, buttons: NPCTalkDialogButtons)
    
    case confirmation(npc: UInt32, message: String)
    
    case getText(npc: UInt32, message: String)
    
    case number(npc: UInt32, message: String, default: UInt32, min: UInt32, max: UInt32)
    
    case simple(npc: UInt32, message: String)
    
    case styles(npc: UInt32, message: String, styles: [UInt32])
    
    case accept(npc: UInt32, message: String)
}

public extension NPCTalkNotification {
    
    var type: NPCTalkType {
        switch self {
        case .dialog:
            return .dialog
        case .confirmation:
            return .confirmation
        case .getText:
            return .getText
        case .number:
            return .number
        case .simple:
            return .simple
        case .styles:
            return .styles
        case .accept:
            return .accept
        }
    }
    
    var npc: UInt32 {
        switch self {
        case .dialog(let npc, _, _):
            return npc
        case .confirmation(let npc, _):
            return npc
        case .getText(let npc, _):
            return npc
        case .number(let npc, _, _, _, _):
            return npc
        case .simple(let npc, _):
            return npc
        case .styles(let npc, _, _):
            return npc
        case .accept(let npc, _):
            return npc
        }
    }
    
    var message: String {
        switch self {
        case .dialog(_, let message, _):
            return message
        case .confirmation(_, let message):
            return message
        case .accept(_, let message):
            return message
        case .number(_, let message, _, _, _):
            return message
        case .simple(_, let message):
            return message
        case .styles(_, let message, _):
            return message
        case .getText(_, let message):
            return message
        }
    }
}

extension NPCTalkNotification: Codable {
    
    static var value0: UInt8 { 4 }
    
    enum CodingKeys: String, CodingKey {
        case value0
        case value1
        case value2
        case npc
        case type
        case message
        case buttons
        case styles
        case `default` = "default"
        case min
        case max
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let value0 = try container.decode(UInt8.self, forKey: .value0)
        guard value0 == Self.value0 else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unexpected value"))
        }
        let npc = try container.decode(UInt32.self, forKey: .npc)
        let type = try container.decode(NPCTalkType.self, forKey: .type)
        let message = try container.decode(String.self, forKey: .message)
        switch type {
        case .dialog:
            let buttons = try container.decode(NPCTalkDialogButtons.self, forKey: .buttons)
            self = .dialog(npc: npc, message: message, buttons: buttons)
        case .confirmation:
            self = .confirmation(npc: npc, message: message)
        case .getText:
            let value1 = try container.decode(UInt32.self, forKey: .value1)
            let value2 = try container.decode(UInt32.self, forKey: .value2)
            guard value1 == 0, value2 == 0 else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unexpected value"))
            }
            self = .getText(npc: npc, message: message)
        case .number:
            let def = try container.decode(UInt32.self, forKey: .default)
            let min = try container.decode(UInt32.self, forKey: .min)
            let max = try container.decode(UInt32.self, forKey: .max)
            let value1 = try container.decode(UInt32.self, forKey: .value1)
            guard value1 == 0 else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unexpected value"))
            }
            self = .number(npc: npc, message: message, default: def, min: min, max: max)
        case .simple:
            self = .simple(npc: npc, message: message)
        case .styles:
            let styles = try container.decode([UInt32].self, forKey: .styles)
            self = .styles(npc: npc, message: message, styles: styles)
        case .accept:
            self = .accept(npc: npc, message: message)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Self.value0, forKey: .value0)
        try container.encode(npc, forKey: .npc)
        try container.encode(type, forKey: .type)
        try container.encode(message, forKey: .message)
        switch self {
        case .dialog(_, _, let buttons):
            try container.encode(buttons, forKey: .buttons)
        case .confirmation:
            break
        case .accept:
            break
        case .simple:
            break
        case .getText:
            try container.encode(UInt32(0), forKey: .value1)
            try container.encode(UInt32(0), forKey: .value2)
        case .number(_, _, let def, let min, let max):
            try container.encode(def, forKey: .default)
            try container.encode(min, forKey: .min)
            try container.encode(max, forKey: .max)
            try container.encode(UInt32(0), forKey: .value1)
        case .styles(_, _, let styles):
            try container.encode(styles, forKey: .styles)
        }
    }
}
