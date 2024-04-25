//
//  User.swift
//
//
//  Created by Alsey Coleman Miller on 4/25/24.
//

import Foundation

/// MapleStory User
public struct User: Codable, Equatable, Hashable {
    
    // MARK: - Properties
    
    public let username: String
    
    public var password: String
    
    public var created: Date
    
    public var pinCode: String?
    
    public var picCode: String?
    
    public var birthday: Date
    
    public var email: String?
    
    public var termsAccepted: Bool
    
    public var isAdmin: Bool
    
    // MARK: - Initialization
    
    public init(
        username: String,
        password: String,
        created: Date = Date(),
        pinCode: String? = nil,
        picCode: String? = nil,
        birthday: Date = Date(timeIntervalSinceReferenceDate: 0),
        email: String? = nil,
        termsAccepted: Bool = false,
        isAdmin: Bool = false
    ) {
        self.username = username
        self.password = password
        self.created = created
        self.pinCode = pinCode
        self.picCode = picCode
        self.birthday = birthday
        self.email = email
        self.termsAccepted = termsAccepted
        self.isAdmin = isAdmin
    }
}

// MARK: - Identifiable

extension User: Identifiable {
    
    public var id: String {
        username
    }
}
