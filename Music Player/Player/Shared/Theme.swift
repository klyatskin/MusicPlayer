//
//  Theme.swift
//  Embedded Music Player
//  Theme (colors, type, spacing)
//
//  Created by Konstantin Klyatskin on 2025-10-17.
//


// Theme.swift
import UIKit

enum Theme {
    enum Color {
        static let background = UIColor(hex: 0x2A2A3D)   // #2A2A3D
        static let selected   = UIColor(hex: 0x004A77)   // sample from spec
        static let barTrack   = UIColor(hex: 0x6B6F7F)
        static let barFill    = UIColor(hex: 0x85A6D6)
        static let chip       = UIColor(hex: 0x555b66)
        static let labelPrimary = UIColor.white
        static let labelSecondary = UIColor.white.withAlphaComponent(0.7)
        static let iconDefault = UIColor.white
        static let iconAccent  = UIColor.systemBlue
        static let heartOn     = UIColor.systemPink
    }

    enum Metrics {
        static let cardCorner: CGFloat = 14
        static let cardHeight: CGFloat = 233
        static let cardRatio: CGFloat =  480 / cardHeight
        static let artSize: CGFloat = 88
        static let largeControl: CGFloat = 72
        static let smallControl: CGFloat = 36
        static let spacing: CGFloat = 12
        static let progressHeight: CGFloat = 3
        static let contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    enum Typography {
        static func title() -> UIFont { .systemFont(ofSize: 24, weight: .semibold) }
        static func subtitle() -> UIFont { .systemFont(ofSize: 16, weight: .regular) }
        static func time() -> UIFont { .monospacedDigitSystemFont(ofSize: 11, weight: .regular) }
    }
}

// MARK: - Utilities
extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xff)/255,
            green: CGFloat((hex >> 8) & 0xff)/255,
            blue: CGFloat(hex & 0xff)/255,
            alpha: alpha
        )
    }
}
