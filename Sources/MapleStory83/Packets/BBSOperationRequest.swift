//
//  BBSOperationRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public enum BBSOperationRequest: MapleStoryPacket, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x86 }
    
    case new(notice: Bool, title: String, body: String, icon: UInt32)
    case edit(id: UInt32, notice: Bool, title: String, body: String, icon: UInt32)
    case delete(id: UInt32)
    case list(id: UInt32)
    case listReply(id: UInt32)
    case reply(id: UInt32, body: String)
    case deleteReply(id: UInt32, reply: UInt32)
}

internal extension BBSOperationRequest {
    
    enum Mode: UInt8, Codable {
        
        case new                = 0
        case delete             = 1
        case list               = 2
        case listReply          = 3
        case reply              = 4
        case deleteReply        = 5
    }
    
    var mode: Mode {
        switch self {
        case .new:
            return .new
        case .edit:
            return .new
        case .delete:
            return .delete
        case .list:
            return .list
        case .listReply:
            return .listReply
        case .reply:
            return .reply
        case .deleteReply:
            return .deleteReply
        }
    }
}

extension BBSOperationRequest: Codable {
    
    enum CodingKeys: String, CodingKey {
        case mode
        case isEdit
        case id
        case title
        case body
        case icon
        case notice
        case reply
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let mode = try container.decode(Mode.self, forKey: .mode)
        switch mode {
        case .new:
            let isEdit = try container.decode(Bool.self, forKey: .isEdit)
            if isEdit {
                let id = try container.decode(UInt32.self, forKey: .id)
                let notice = try container.decode(Bool.self, forKey: .notice)
                let title = try container.decode(String.self, forKey: .title)
                let body = try container.decode(String.self, forKey: .body)
                let icon = try container.decode(UInt32.self, forKey: .icon)
                self = .edit(id: id, notice: notice, title: title, body: body, icon: icon)
            } else {
                let notice = try container.decode(Bool.self, forKey: .notice)
                let title = try container.decode(String.self, forKey: .title)
                let body = try container.decode(String.self, forKey: .body)
                let icon = try container.decode(UInt32.self, forKey: .icon)
                self = .new(notice: notice, title: title, body: body, icon: icon)
            }
        case .delete:
            let id = try container.decode(UInt32.self, forKey: .id)
            self = .delete(id: id)
        case .list:
            let id = try container.decode(UInt32.self, forKey: .id)
            self = .list(id: id)
        case .listReply:
            let id = try container.decode(UInt32.self, forKey: .id)
            self = .listReply(id: id)
        case .reply:
            let id = try container.decode(UInt32.self, forKey: .id)
            let body = try container.decode(String.self, forKey: .body)
            self = .reply(id: id, body: body)
        case .deleteReply:
            let id = try container.decode(UInt32.self, forKey: .id)
            let reply = try container.decode(UInt32.self, forKey: .reply)
            self = .deleteReply(id: id, reply: reply)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mode, forKey: .mode)
        switch self {
        case .new(let notice, let title, let body, let icon):
            let isEdit = false
            try container.encode(isEdit, forKey: .isEdit)
            try container.encode(notice, forKey: .notice)
            try container.encode(title, forKey: .title)
            try container.encode(body, forKey: .body)
            try container.encode(icon, forKey: .icon)
        case .edit(let id, let notice, let title, let body, let icon):
            let isEdit = true
            try container.encode(isEdit, forKey: .isEdit)
            try container.encode(id, forKey: .id)
            try container.encode(notice, forKey: .notice)
            try container.encode(title, forKey: .title)
            try container.encode(body, forKey: .body)
            try container.encode(icon, forKey: .icon)
        case .delete(let id):
            try container.encode(id, forKey: .id)
        case .list(let id):
            try container.encode(id, forKey: .id)
        case .listReply(let id):
            try container.encode(id, forKey: .id)
        case .reply(let id, let body):
            try container.encode(id, forKey: .id)
            try container.encode(body, forKey: .body)
        case .deleteReply(let id, let reply):
            try container.encode(id, forKey: .id)
            try container.encode(reply, forKey: .reply)
        }
    }
}
