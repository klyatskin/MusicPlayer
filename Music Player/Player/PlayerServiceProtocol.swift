//
//  PlayerServiceProtocol.swift
//  Embedded Music Player
//
//  Created by Konstantin Klyatskin on 2025-10-17.
//


// PlayerServiceTypes.swift
import Foundation

protocol PlayerServiceDelegate: AnyObject {
    func playerDidChange(isPlaying: Bool)
    func playerTimeDidUpdate(current: TimeInterval, duration: TimeInterval)
    func playerDidEnd()
}

protocol PlayerServiceProtocol: AnyObject {
    var delegate: PlayerServiceDelegate? { get set }
    var isPlaying: Bool { get }
    var duration: TimeInterval { get }
    var currentTime: TimeInterval { get }

    func load(_ track: Track)
    func play()
    func pause()
    func seek(to seconds: TimeInterval)
}
