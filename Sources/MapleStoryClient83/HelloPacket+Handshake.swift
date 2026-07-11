//
//  HelloPacket+Handshake.swift
//  MapleStoryClient83
//

import MapleStory
import MapleStory83
import MapleStoryClient

/// The v83 ``HelloPacket`` already carries the version, region, and both nonces,
/// so it satisfies ``HandshakePacket`` directly.
extension MapleStory83.HelloPacket: HandshakePacket {}

/// The concrete v83 client session type.
typealias V83Client = MapleStoryClient<
    MapleStorySocketIPv4TCP,
    MapleStory83.HelloPacket,
    MapleStory83.ClientOpcode,
    MapleStory83.ServerOpcode
>
