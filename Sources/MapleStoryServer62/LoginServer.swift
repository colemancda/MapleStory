//
//  LoginServer.swift
//
//
//  Created by Alsey Coleman Miller on 4/25/24.
//

import Foundation
import MapleStory
import Socket
import CoreModel

public final class LoginServer <Store: ModelStorage> {
    
    public let storage: Store
    
    public init(storage: Store) {
        self.storage = storage
    }
}
