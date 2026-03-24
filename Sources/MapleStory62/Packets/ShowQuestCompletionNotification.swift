//
//  ShowQuestCompletionNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory

/// Shows quest completion effect and reward window
public struct ShowQuestCompletionNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .showQuestCompletion }

    /// Quest ID
    public let questID: UInt16

    /// Reward selection (for multiple reward options)
    public let selection: UInt8

    /// EXP reward
    public let expReward: UInt32

    /// Meso reward
    public let mesoReward: UInt32

    /// Item rewards (item ID -> quantity)
    public let items: [UInt32: UInt16]

    /// Create quest completion notification
    public init(
        questID: UInt16,
        selection: UInt8 = 0,
        expReward: UInt32 = 0,
        mesoReward: UInt32 = 0,
        items: [UInt32: UInt16] = [:]
    ) {
        self.questID = questID
        self.selection = selection
        self.expReward = expReward
        self.mesoReward = mesoReward
        self.items = items
    }
}
