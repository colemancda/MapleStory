//
//  AudioPlayer.swift
//  MapleStoryClient
//
//  Background-music playback for WZ-extracted audio (MP3), via AVFoundation.
//

import Foundation
import AVFoundation

/// Plays looping background music from in-memory audio data.
public final class AudioPlayer {

    private var player: AVAudioPlayer?
    private var currentTrack: String?

    public init() {}

    /// Play `data` on loop, identified by `track` (e.g. "Bgm00/FloralLife").
    /// Restarting the same track is a no-op; a different track replaces it.
    public func playMusic(_ data: Data, track: String) {
        guard track != currentTrack else { return }
        player?.stop()
        do {
            let player = try AVAudioPlayer(data: data)
            player.numberOfLoops = -1
            player.play()
            self.player = player
            self.currentTrack = track
        } catch {
            self.player = nil
            self.currentTrack = nil
        }
    }

    public func stop() {
        player?.stop()
        player = nil
        currentTrack = nil
    }

    public var isPlaying: Bool { player?.isPlaying ?? false }
}
