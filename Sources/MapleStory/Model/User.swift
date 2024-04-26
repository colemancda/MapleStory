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
    
    // MARK: - Properties
    
    public let id: Username
    
    public var username: Username {
        id
    }
    
    public var password: String
    
    public var created: Date
    
    public var pinCode: String?
    
    public var picCode: String?
    
    public var birthday: Date
    
    public var email: String?
    
    public var termsAccepted: Bool
    
    public var isAdmin: Bool
    
    public var characters: [Character.ID]
    
    // MARK: - Initialization
    
    public init(
        username: Username,
        password: String,
        created: Date = Date(),
        pinCode: String? = nil,
        picCode: String? = nil,
        birthday: Date = Date(timeIntervalSinceReferenceDate: 0),
        email: String? = nil,
        termsAccepted: Bool = false,
        isAdmin: Bool = false,
        characters: [Character.ID] = []
    ) {
        self.id = username
        self.password = password
        self.created = created
        self.pinCode = pinCode
        self.picCode = picCode
        self.birthday = birthday
        self.email = email
        self.termsAccepted = termsAccepted
        self.isAdmin = isAdmin
        self.characters = characters
    }
    
    public enum CodingKeys: String, CodingKey {
        case id
        case password
        case created
        case pinCode
        case picCode
        case birthday
        case email
        case termsAccepted
        case isAdmin
        case characters
    }
}

// MARK: - Entity

extension User: Entity {
    
    public static var attributes: [CodingKeys: AttributeType] {
        [
            .password: .string,
            .created: .date,
            .pinCode: .string,
            .picCode: .string,
            .birthday: .date,
            .email: .string,
            .termsAccepted: .bool,
            .isAdmin: .bool,
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

extension Username: ObjectIDConvertible {
    
    public init?(objectID: ObjectID) {
        self.init(rawValue: objectID.rawValue)
    }
}
