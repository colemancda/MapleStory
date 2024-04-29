//
//  User.swift
//
//
//  Created by Alsey Coleman Miller on 4/25/24.
//

import Foundation
import CoreModel

/// MapleStory User
public struct User: Codable, Equatable, Hashable, Identifiable, Sendable {
    
    public typealias Index = UInt32
    
    // MARK: - Properties
    
    public let id: UUID
    
    public let index: Index
    
    public let username: Username
    
    /// Password hash
    public var password: Data
    
    public var created: Date
    
    public let gender: Gender
    
    public var ipAddress: String?
    
    public var pinCode: String?
    
    public var picCode: String?
    
    public var birthday: Date?
    
    public var email: String?
    
    public var termsAccepted: Bool
    
    public var isAdmin: Bool
    
    public var isGuest: Bool
        
    public var characters: [Character.ID]
    
    // MARK: - Initialization
    
    public init(
        id: UUID = UUID(),
        index: Index,
        username: Username,
        password: Data = Data(),
        created: Date = Date(),
        gender: Gender = .male,
        ipAddress: String? = nil,
        pinCode: String? = nil,
        picCode: String? = nil,
        birthday: Date? = nil,
        email: String? = nil,
        termsAccepted: Bool = false,
        isAdmin: Bool = false,
        isGuest: Bool = false,
        characters: [Character.ID] = []
    ) {
        self.id = id
        self.index = index
        self.username = username
        self.gender = gender
        self.password = password
        self.created = created
        self.ipAddress = ipAddress
        self.pinCode = pinCode
        self.picCode = picCode
        self.birthday = birthday
        self.email = email
        self.termsAccepted = termsAccepted
        self.isAdmin = isAdmin
        self.isGuest = isGuest
        self.characters = characters
    }
    
    public enum CodingKeys: String, CodingKey, CaseIterable {
        
        case id
        case index
        case username
        case password
        case created
        case gender
        case ipAddress = "ip"
        case pinCode = "pin"
        case picCode = "pic"
        case birthday
        case email
        case termsAccepted
        case isAdmin = "admin"
        case isGuest = "guest"
        case characters
    }
}

// MARK: - Entity

extension User: Entity {
    
    public static var attributes: [CodingKeys: AttributeType] {
        [
            .index: .int64,
            .username: .string,
            .password: .data,
            .created: .date,
            .gender: .int16,
            .ipAddress: .string,
            .pinCode: .string,
            .picCode: .string,
            .birthday: .date,
            .email: .string,
            .termsAccepted: .bool,
            .isAdmin: .bool,
            .isGuest: .bool
        ]
    }
    
    public static var relationships: [CodingKeys: Relationship] {
        [
            .characters: Relationship(
                id: .characters,
                entity: User.self,
                destination: Character.self,
                type: .toMany,
                inverseRelationship: .user
            )
        ]
    }
}
