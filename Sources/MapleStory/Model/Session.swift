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
