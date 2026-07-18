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
    
    public var gender: Gender?
    
    public var ipAddress: String?
    
    public var pinCode: String?
    
    public var picCode: String?
    
    public var birthday: Date
    
    public var email: String?
    
    public var termsAccepted: Bool
    
    public var isAdmin: Bool
    
    public var isGuest: Bool
        
    public var characters: [Character.ID]
    
    /// Storage ID
    public var storage: Storage.ID?
    
    // MARK: - Initialization
    
    public init(
        id: UUID = UUID(),
        index: Index,
        username: Username,
        password: Data = Data(),
        created: Date = Date(),
        gender: Gender? = nil,
        ipAddress: String? = nil,
        pinCode: String? = nil,
        picCode: String? = nil,
        birthday: Date = .mapleGlobalRelease,
        email: String? = nil,
        termsAccepted: Bool = false,
        isAdmin: Bool = false,
        isGuest: Bool = false,
        characters: [Character.ID] = [],
        storage: Storage.ID? = nil
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
        case storage
    }
}

// MARK: - Entity

extension User: Entity {

    public init(from container: ModelData) throws {
        guard container.entity.rawValue == Self.entityName.rawValue else {
            throw CoreModel.CoreModelError.invalidEntity(container.entity)
        }
        guard let id = Self.ID(objectID: container.id) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Cannot decode identifier from \(container.id)"))
        }
        self.id = id
        self.index = try container.decode(Index.self, forKey: User.CodingKeys.index)
        self.username = try container.decode(Username.self, forKey: User.CodingKeys.username)
        self.password = try container.decode(Data.self, forKey: User.CodingKeys.password)
        self.created = try container.decode(Date.self, forKey: User.CodingKeys.created)
        self.gender = try container.decode(Gender?.self, forKey: User.CodingKeys.gender)
        self.ipAddress = try container.decode(String?.self, forKey: User.CodingKeys.ipAddress)
        self.pinCode = try container.decode(String?.self, forKey: User.CodingKeys.pinCode)
        self.picCode = try container.decode(String?.self, forKey: User.CodingKeys.picCode)
        self.birthday = try container.decode(Date.self, forKey: User.CodingKeys.birthday)
        self.email = try container.decode(String?.self, forKey: User.CodingKeys.email)
        self.termsAccepted = try container.decode(Bool.self, forKey: User.CodingKeys.termsAccepted)
        self.isAdmin = try container.decode(Bool.self, forKey: User.CodingKeys.isAdmin)
        self.isGuest = try container.decode(Bool.self, forKey: User.CodingKeys.isGuest)
        self.characters = try container.decodeRelationship([Character.ID].self, forKey: User.CodingKeys.characters)
        self.storage = try container.decodeRelationship(Storage.ID?.self, forKey: User.CodingKeys.storage)
    }

    public func encode() -> ModelData {
        var container = ModelData(
            entity: Self.entityName,
            id: ObjectID(self.id)
        )
        container.encode(self.index, forKey: User.CodingKeys.index)
        container.encode(self.username, forKey: User.CodingKeys.username)
        container.encode(self.password, forKey: User.CodingKeys.password)
        container.encode(self.created, forKey: User.CodingKeys.created)
        container.encode(self.gender, forKey: User.CodingKeys.gender)
        container.encode(self.ipAddress, forKey: User.CodingKeys.ipAddress)
        container.encode(self.pinCode, forKey: User.CodingKeys.pinCode)
        container.encode(self.picCode, forKey: User.CodingKeys.picCode)
        container.encode(self.birthday, forKey: User.CodingKeys.birthday)
        container.encode(self.email, forKey: User.CodingKeys.email)
        container.encode(self.termsAccepted, forKey: User.CodingKeys.termsAccepted)
        container.encode(self.isAdmin, forKey: User.CodingKeys.isAdmin)
        container.encode(self.isGuest, forKey: User.CodingKeys.isGuest)
        container.encodeRelationship(self.characters, forKey: User.CodingKeys.characters)
        container.encodeRelationship(self.storage, forKey: User.CodingKeys.storage)
        return container
    }

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
            ),
            .storage: Relationship(
                id: .storage,
                entity: User.self,
                destination: Storage.self,
                type: .toOne,
                inverseRelationship: .userID
            )
        ]
    }
}
