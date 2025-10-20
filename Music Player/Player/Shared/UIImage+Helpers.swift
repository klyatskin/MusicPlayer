//
//  UIImage+Symbols.swift
//  Embedded Music Player
//
//  Created by Konstantin Klyatskin on 2025-10-17.
//

import UIKit

extension UIImage {
    static func sfsymbol(_ name: String) -> UIImage? {
        UIImage(systemName: name, withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))
    }
}

extension UIImage {
    static func placeholderArtwork(size: CGFloat = Theme.Metrics.artSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        // Background gradient-ish stripes
        let colors: [UIColor] = [Theme.Color.selected, Theme.Color.barFill, Theme.Color.chip]
        for (i, c) in colors.enumerated() {
            c.setFill()
            let slice = CGRect(x: 0, y: CGFloat(i) * rect.height / 3, width: rect.width, height: rect.height / 3)
            ctx.fill(slice)
        }
        // Draw a large music note SF Symbol in center
        if let note = UIImage(systemName: "music.note") {
            let scale: CGFloat = 0.55
            let w = rect.width * scale
            let h = rect.height * scale
            let x = (rect.width - w) / 2
            let y = (rect.height - h) / 2
            Theme.Color.labelPrimary.withAlphaComponent(0.9).set()
            note.withTintColor(Theme.Color.labelPrimary, renderingMode: .alwaysOriginal)
                .draw(in: CGRect(x: x, y: y, width: w, height: h))
        }
        let img = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return img
    }
}
