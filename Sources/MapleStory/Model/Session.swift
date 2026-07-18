//
//  Session.swift
//
//
//  Created by Alsey Coleman Miller on 5/3/24.
//

import Foundation
import CoreModel

/// MapleStory Game Session
public struct Session: Codable, Equatable, Hashable, Identifiable, Sendable {
    
    // MARK: - Properties
    
    public let id: UUID
    
    public let channel: Channel.ID
    
    public let character: Character.ID
    
    public let requestTime: Date
    
    public var loginTime: Date?
    
    public let sendNonce: Nonce
    
    public let recieveNonce: Nonce
    
    public var address: String
    
    // MARK: - Initialization
    
    public init(
        id: UUID = UUID(),
        channel: Channel.ID,
        character: Character.ID,
        requestTime: Date = Date(),
        loginTime: Date? = nil,
        sendNonce: Nonce,
        recieveNonce: Nonce,
        address: String
    ) {
        self.id = id
        self.channel = channel
        self.character = character
        self.requestTime = requestTime
        self.loginTime = loginTime
        self.sendNonce = sendNonce
        self.recieveNonce = recieveNonce
        self.address = address
    }
    
    // MARK: - Codable
    
    public enum CodingKeys: String, CodingKey, CaseIterable, Sendable {
        
        case id
        case channel
        case character
        case requestTime
        case loginTime
        case sendNonce
        case recieveNonce
        case address
    }
}

// MARK: - Entity

extension Session: Entity {

    public init(from container: ModelData) throws {
        guard container.entity.rawValue == Self.entityName.rawValue else {
            throw CoreModel.CoreModelError.invalidEntity(container.entity)
        }
        guard let id = Self.ID(objectID: container.id) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Cannot decode identifier from \(container.id)"))
        }
        self.id = id
        self.requestTime = try container.decode(Date.self, forKey: Session.CodingKeys.requestTime)
        self.loginTime = try container.decode(Date?.self, forKey: Session.CodingKeys.loginTime)
        self.sendNonce = try container.decode(Nonce.self, forKey: Session.CodingKeys.sendNonce)
        self.recieveNonce = try container.decode(Nonce.self, forKey: Session.CodingKeys.recieveNonce)
        self.address = try container.decode(String.self, forKey: Session.CodingKeys.address)
        self.channel = try container.decodeRelationship(Channel.ID.self, forKey: Session.CodingKeys.channel)
        self.character = try container.decodeRelationship(Character.ID.self, forKey: Session.CodingKeys.character)
    }

    public func encode() -> ModelData {
        var container = ModelData(
            entity: Self.entityName,
            id: ObjectID(self.id)
        )
        container.encode(self.requestTime, forKey: Session.CodingKeys.requestTime)
        container.encode(self.loginTime, forKey: Session.CodingKeys.loginTime)
        container.encode(self.sendNonce, forKey: Session.CodingKeys.sendNonce)
        container.encode(self.recieveNonce, forKey: Session.CodingKeys.recieveNonce)
        container.encode(self.address, forKey: Session.CodingKeys.address)
        container.encodeRelationship(self.channel, forKey: Session.CodingKeys.channel)
        container.encodeRelationship(self.character, forKey: Session.CodingKeys.character)
        return container
    }

    public static var attributes: [CodingKeys: AttributeType] {
        [
            .requestTime: .date,
            .loginTime: .date,
            .sendNonce: .int64,
            .recieveNonce: .int64,
            .address: .string
        ]
    }
    
    public static var relationships: [CodingKeys: Relationship] {
        [
            .channel: Relationship(
                id: .channel,
                entity: Session.self,
                destination: Channel.self,
                type: .toOne,
                inverseRelationship: .sessions
            ),
            .character: Relationship(
                id: .character,
                entity: Session.self,
                destination: Character.self,
                type: .toOne,
                inverseRelationship: .session
            )
        ]
    }
}
