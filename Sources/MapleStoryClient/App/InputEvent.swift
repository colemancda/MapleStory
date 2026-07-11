//
//  InputEvent.swift
//  MapleStoryClient
//
//  A small, SDL-independent input abstraction so scene code (including the
//  executable) never has to import SDL directly.
//

import Foundation

/// A non-character control key.
public enum ControlKey: Sendable, Equatable {
    case enter
    case backspace
    case escape
    case tab
    case up
    case down
    case left
    case right
}

/// A translated input event delivered to the active ``Scene``.
public enum InputEvent: Sendable {
    /// A printable character was typed.
    case character(Character)
    /// A control key was pressed.
    case control(ControlKey)
    /// A mouse button was pressed at the given pixel coordinate.
    case mouseDown(x: Float, y: Float)
    /// The window was resized.
    case resize(width: Int, height: Int)
    /// The application was asked to quit.
    case quit
}
