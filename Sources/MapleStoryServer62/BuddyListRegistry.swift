//
//  BuddyListRegistry.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62

public actor BuddyListRegistry {

    public static let shared = BuddyListRegistry()

    private var lists: [Character.ID: [BuddyListNotification.Buddy]] = [:]

    private init() { }

    public func list(for characterID: Character.ID) -> [BuddyListNotification.Buddy] {
        lists[characterID] ?? []
    }

    public func add(_ buddy: BuddyListNotification.Buddy, to characterID: Character.ID) -> Bool {
        var current = lists[characterID] ?? []
        guard current.contains(where: { $0.id == buddy.id }) == false else {
            return false
        }
        current.append(buddy)
        current.sort { $0.name.rawValue < $1.name.rawValue }
        lists[characterID] = current
        return true
    }

    public func remove(buddyID: UInt32, from characterID: Character.ID) -> Bool {
        var current = lists[characterID] ?? []
        let originalCount = current.count
        current.removeAll { $0.id == buddyID }
        guard current.count != originalCount else {
            return false
        }
        lists[characterID] = current
        return true
    }
}
