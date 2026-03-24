//
//  Guild.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel

/// Guild ID
public typealias GuildID = UInt32

/// Guild member rank
public enum GuildRank: UInt8, Codable, Equatable, Hashable, Sendable {
    case master = 1      // Guild Master
    case jrMaster = 2    // Junior Master
    case member = 3      // Regular Member
    case unavailable = 5 // Left guild
}

/// Guild member data
public struct GuildMember: Codable, Equatable, Hashable, Sendable {

    public let characterID: Character.ID

    public let characterName: CharacterName

    public var rank: GuildRank

    public var online: Bool

    public init(
        characterID: Character.ID,
        characterName: CharacterName,
        rank: GuildRank = .member,
        online: Bool = false
    ) {
        self.characterID = characterID
        self.characterName = characterName
        self.rank = rank
        self.online = online
    }
}

/// Guild
public struct Guild: Codable, Equatable, Hashable, Identifiable, Sendable {

    public let id: GuildID

    /// Guild name
    public var name: String

    /// Guild leader
    public var leaderID: Character.ID

    /// Guild members
    public var members: [Character.ID: GuildMember]

    /// Current member count
    public var memberCount: Int {
        members.count
    }

    /// Maximum capacity (can be expanded)
    public var capacity: Int

    /// Guild points (GP)
    public var points: UInt32

    /// Guild logo background color
    public var logoBackground: UInt8

    /// Guild logo background color
    public var logoBackgroundColor: UInt8

    /// Guild logo
    public var logo: UInt8

    /// Guild logo color
    public var logoColor: UInt8

    /// Check if guild is full
    public var isFull: Bool {
        members.count >= capacity
    }

    public init(
        id: GuildID = GuildID(UInt32.random(in: 1000...999999)),
        name: String,
        leaderID: Character.ID,
        members: [Character.ID: GuildMember] = [:],
        capacity: Int = 30,
        points: UInt32 = 0,
        logoBackground: UInt8 = 0,
        logoBackgroundColor: UInt8 = 0,
        logo: UInt8 = 0,
        logoColor: UInt8 = 0
    ) {
        self.id = id
        self.name = name
        self.leaderID = leaderID
        self.members = members
        self.capacity = capacity
        self.points = points
        self.logoBackground = logoBackground
        self.logoBackgroundColor = logoBackgroundColor
        self.logo = logo
        self.logoColor = logoColor
    }
}
