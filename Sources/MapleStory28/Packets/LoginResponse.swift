//
//  LoginResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 5/1/24.
//

import Foundation
import MapleStory

/// Login Response
public enum LoginResponse: MapleStoryPacket, Equatable, Codable, Hashable, Sendable {
    
    public static var opcode: ServerOpcode { .loginResponse }
    
    /// Successful authentication
    case success(Success)
    
    case permanentBan
    
    case temporaryBan(LoginError, KoreanDate)
    
    case failure(LoginError)
}

// MARK: - Codable

extension LoginResponse: MapleStoryCodable {
    
    enum MapleCodingKeys: String, CodingKey {
        case success
        case ban
        case failure
    }
    
    public init(from container: MapleStoryDecodingContainer) throws {
        let status = container.peek()
        switch status {
        case 0x00:
            let value = try container.decode(Success.self, forKey: MapleCodingKeys.success)
            self = .success(value)
        case 0x02:
            let value = try container.decode(Ban.self, forKey: MapleCodingKeys.ban)
            if value.reason == 0x00 {
                self = .permanentBan
            } else {
                guard let reason = LoginError(rawValue: value.reason) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Invalid reason \(value.reason)"))
                }
                self = .temporaryBan(reason, value.timestamp)
            }
        default:
            let value = try container.decode(Failure.self, forKey: MapleCodingKeys.failure)
            self = .failure(value.status)
        }
    }
    
    public func encode(to container: MapleStoryEncodingContainer) throws {
        switch self {
        case let .success(value):
            try container.encode(value, forKey: MapleCodingKeys.success)
        case .permanentBan:
            let value = Ban.permanent
            try container.encode(value, forKey: MapleCodingKeys.ban)
        case let .temporaryBan(reason, timestamp):
            let value = Ban(reason: reason, timestamp: timestamp)
            try container.encode(value, forKey: MapleCodingKeys.ban)
        case let .failure(error):
            let failure = Failure(status: error)
            try container.encode(failure, forKey: MapleCodingKeys.failure)
        }
    }
}

// MARK: - Supporting Types

public extension LoginResponse {
    
    struct Success: Equatable, Hashable, Codable, Sendable {
        
        internal let value0: UInt8
        
        internal let value1: UInt8
        
        internal let value2: UInt32
        
        public let account: User.Index
        
        public let gender: LoginResponse.Success.Gender
        
        public let isAdmin: Bool
        
        public let value3: UInt8
        
        public let username: String
        
        internal let value4: UInt64
        
        internal let value5: UInt64
        
        internal let value6: UInt64
        
        public init(
            account: User.Index,
            gender: Gender,
            isAdmin: Bool = false,
            username: String
        ) {
            self.value0 = 0x00
            self.value1 = 0x00
            self.value2 = 0x00
            self.value3 = 0x01
            self.value4 = 0x00
            self.value5 = 0x00
            self.value6 = 0x00
            self.account = account
            self.gender = gender
            self.isAdmin = isAdmin
            self.username = username
        }
    }
}

public extension LoginResponse.Success {
    
    init(user: User) {
        self.init(
            account: user.index,
            gender: .init(user.gender),
            isAdmin: user.isAdmin,
            username: user.username.rawValue
        )
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
        
        let status: LoginError
        
        let value0: UInt8
        
        let value1: UInt32
        
        let value2: UInt64
        
        let value3: UInt64
        
        let value4: UInt64
        
        init(status: LoginError) {
            self.status = status
            self.value0 = 0
            self.value1 = 0
            self.value2 = 0
            self.value3 = 0
            self.value4 = 0
        }
    }
}

internal extension LoginResponse {
    
    struct Ban: Equatable, Hashable, Codable, Sendable, Error {
        
        let status: UInt8
        
        let value0: UInt8
        
        let value1: UInt32
        
        let reason: UInt8
        
        let timestamp: KoreanDate
        
        let value2: UInt64
        
        let value3: UInt64
        
        let value4: UInt64
        
        init(reason: LoginError, timestamp: KoreanDate) {
            self.status = 0x02
            self.value0 = 0
            self.value1 = 0
            self.value2 = 0
            self.value3 = 0
            self.value4 = 0
            self.reason = reason.rawValue
            self.timestamp = timestamp
        }
        
        init(reason: UInt8, timestamp: KoreanDate) {
            self.status = 0x02
            self.value0 = 0
            self.value1 = 0
            self.value2 = 0
            self.value3 = 0
            self.value4 = 0
            self.reason = reason
            self.timestamp = timestamp
        }
        
        static var permanent: Ban {
            .init(reason: 0x00, timestamp: .default)
        }
    }
}
