//
//  Track.swift
//  Embedded Music Player
//
//  Created by Konstantin Klyatskin on 2025-10-17.
//

import Foundation

struct Track {
    let title: String
    let subtitle: String
    let artworkURL: URL
    let streamURL: URL
    let durationHint: TimeInterval?
    
    static var sampleTrack: Track {
        let url = URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3")!
        let art = URL(string: "https://picsum.photos/seed/geminiplay/256")!
        return Track(title: "SoundHelix Song 1",
                     subtitle: "Demo Artist",
                     artworkURL: art,
                     streamURL: url,
                     durationHint: 0)
    }
}


