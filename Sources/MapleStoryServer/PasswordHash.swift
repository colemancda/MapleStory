//
//  Password.swift
//
//
//  Created by Alsey Coleman Miller on 4/26/24.
//

import Foundation
import MapleStory
import Argon2Swift

public extension User {
    
    func validate(password: String) throws -> Bool {
        guard let password = Password(rawValue: password) else {
            return false
        }
        let hash = self.password
        return try password.validate(hash: hash)
    }
}

public extension Password {
    
    /// Hash password.
    func hash() throws -> Data {
        let salt = Salt.newSalt()
        let result = try Argon2Swift.hashPasswordBytes(password: Data(rawValue.utf8), salt: salt)
        return result.encodedData()
    }
    
    func validate(hash: Data) throws -> Bool {
        return try Argon2Swift.verifyHashBytes(password: Data(rawValue.utf8), hash: hash)
    }
}
