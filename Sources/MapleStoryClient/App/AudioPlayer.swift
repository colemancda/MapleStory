//
//  AudioPlayer.swift
//  MapleStoryClient
//
//  Background-music and sound-effect playback for WZ-extracted audio (MP3),
//  via AVFoundation.
//

import Foundation
import AVFoundation

/// Plays looping background music and one-shot sound effects from in-memory
/// audio data.
public final class AudioPlayer {

    private var player: AVAudioPlayer?
    private var currentTrack: String?
    /// One-shot effects currently playing (kept alive until finished).
    private var effects: [AVAudioPlayer] = []

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

    /// Play `data` once, overlapping music and other effects.
    public func playEffect(_ data: Data) {
        effects.removeAll { $0.isPlaying == false }
        guard let effect = try? AVAudioPlayer(data: data) else { return }
        effect.play()
        effects.append(effect)
    }

    public func stop() {
        player?.stop()
        player = nil
        currentTrack = nil
        effects.forEach { $0.stop() }
        effects.removeAll()
    }

    public var isPlaying: Bool { player?.isPlaying ?? false }
}
