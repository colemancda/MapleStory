//
//  LoginResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 4/27/24.
//

import Foundation
import MapleStory

/// Login Response
public enum LoginResponse: MapleStoryPacket, Equatable, Codable, Hashable, Sendable {
    
    public static var opcode: Opcode { .init(server: .loginStatus) }
    
    /// Successful authentication and PIN Request packet.
    case success(Success)
    
    case permanentBan
    
    case temporaryBan(LoginError, KoreanDate)
    
    case failure(LoginError)
}

// MARK: - Codable

extension LoginResponse: MapleStoryCodable {
    
    enum MapleCodingKeys: String, CodingKey {
        case header
        case success
        case ban
        case failure
    }
    
    public init(from container: MapleStoryDecodingContainer) throws {
        let header = try container.decode(Header.self, forKey: MapleCodingKeys.header)
        switch header.status {
        case 0x00:
            let value = try container.decode(Success.self, forKey: MapleCodingKeys.success)
            self = .success(value)
        case 0x02:
            fatalError("TODO")
        default:
            guard let reason = LoginError(rawValue: header.status) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Invalid status \(header.status)"))
            }
            self = .failure(reason)
        }
    }
    
    public func encode(to container: MapleStoryEncodingContainer) throws {
        switch self {
        case let .success(value):
            try container.encode(Header(status: value.status), forKey: MapleCodingKeys.header)
            try container.encode(value, forKey: MapleCodingKeys.success)
        case .permanentBan:
            let value = Ban.permanent
            try container.encode(Header(status: value.status), forKey: MapleCodingKeys.header)
            try container.encode(value, forKey: MapleCodingKeys.ban)
        case let .temporaryBan(reason, timestamp):
            let value = Ban(reason: reason, timestamp: timestamp)
            try container.encode(Header(status: value.status), forKey: MapleCodingKeys.header)
        case let .failure(failure):
            try container.encode(Header(status: failure.rawValue), forKey: MapleCodingKeys.header)
        }
    }
}

// MARK: - Supporting Types

internal extension LoginResponse {
    
    struct Header: Equatable, Hashable, Codable, Sendable  {
        
        var status: UInt8
        
        let value0: UInt8
        
        let value1: UInt32
        
        init(status: UInt8) {
            self.status = status
            self.value0 = 0
            self.value1 = 0
        }
    }
}

public extension LoginResponse {
    
    struct Success: Equatable, Hashable, Codable, Sendable {
        
        var status: UInt8 { 0x00 }
        
        internal let account: User.Index
        
        public let gender: LoginResponse.Success.Gender
        
        public let isAdmin: Bool
        
        public let adminType: UInt8 // 0x80, 0x40, 0x20
        
        public let countryCode: UInt8
                
        public let username: String
        
        public let value2: UInt8
        
        public let isQuietBan: Bool
        
        public let quietBanTimeStamp: UInt64
        
        public let creationTimeStamp: UInt64
        
        public let skipWorldSelectionPrompt: Bool
        
        public let skipPin: Bool
        
        public let picMode: PicMode
        
        public init(
            account: User.Index,
            gender: Gender,
            isAdmin: Bool = false,
            adminType: UInt8 = 0,
            countryCode: UInt8 = 0,
            username: String,
            isQuietBan: Bool = false,
            quietBanTimeStamp: UInt64 = 0,
            creationTimeStamp: UInt64 = 0,
            skipWorldSelectionPrompt: Bool = true,
            skipPin: Bool = true,
            picMode: PicMode = .disabled
        ) {
            self.account = account
            self.gender = gender
            self.isAdmin = isAdmin
            self.adminType = adminType
            self.countryCode = countryCode
            self.username = username
            self.value2 = 0
            self.isQuietBan = isQuietBan
            self.quietBanTimeStamp = quietBanTimeStamp
            self.creationTimeStamp = creationTimeStamp
            self.skipWorldSelectionPrompt = skipWorldSelectionPrompt
            self.skipPin = skipPin
            self.picMode = picMode
        }
    }
}

public extension LoginResponse.Success {
    
    init(user: User) {
        self.init(
            account: user.index,
            gender: .init(user.gender),
            isAdmin: user.isAdmin,
            adminType: user.isAdmin ? 0x80 : 0x00,
            countryCode: 0, // TODO: Country code
            username: user.username.rawValue,
            isQuietBan: false,
            quietBanTimeStamp: 0,
            creationTimeStamp: 0,
            skipWorldSelectionPrompt: true, // TODO: Customize world selection
            skipPin: true,  // TODO: Customize PIN code
            picMode: .disabled
        )
    }
}

public extension LoginResponse.Success {
    
    enum PicMode: UInt8, Codable, CaseIterable, Sendable {
        
        /// Register PIC
        case register
        
        /// Ask for PIC
        case enabled
        
        /// Disabled
        case disabled
    }
}

public extension LoginResponse.Success {
    
    enum Gender: UInt8, Codable, CaseIterable, Sendable {
        
        case male       = 0
        case female     = 1
        case none       = 10
    }
}

public extension LoginResponse.Success.Gender {
    
    init(_ gender: MapleStory.Gender?) {
        switch gender {
        case .male:
            self = .male
        case .female:
            self = .female
        case .none:
            self = .none
        }
    }
}

internal extension LoginResponse {
    
    struct Failure: Equatable, Hashable, Codable, Sendable  {
        
        var status: UInt8
        
        let value0: UInt8
        
        let value1: UInt32
        
        init(status: UInt8) {
            self.status = status
            self.value0 = 0
            self.value1 = 0
        }
    }
}

internal extension LoginResponse {
    
    struct Ban: Equatable, Hashable, Codable, Sendable, Error {
        
        var status: UInt8 { 0x02 }
        
        let reason: UInt8
        
        let timestamp: KoreanDate
        
        init(reason: LoginError, timestamp: KoreanDate) {
            self.reason = reason.rawValue
            self.timestamp = timestamp
        }
        
        init(reason: UInt8, timestamp: KoreanDate) {
            self.reason = reason
            self.timestamp = timestamp
        }
        
        static var permanent: Ban {
            .init(reason: 0x00, timestamp: .default)
        }
    }
}
