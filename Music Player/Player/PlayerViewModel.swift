//
//  PlayerViewModel.swift
//  Embedded Music Player
//
//  Created by Konstantin Klyatskin on 2025-10-17.
//


// PlayerViewModel.swift
import Foundation

protocol PlayerViewModelDelegate: AnyObject {
    func viewModelDidUpdate(_ snapshot: PlayerViewModel.Snapshot)
}

final class PlayerViewModel {
    struct Snapshot {
        let title: String
        let subtitle: String
        let isPlaying: Bool
        let current: TimeInterval
        let duration: TimeInterval
    }

    private let service: PlayerServiceProtocol
    weak var delegate: PlayerViewModelDelegate?

    private(set) var currentTrack: Track?

    init(service: PlayerServiceProtocol) {
        self.service = service
        service.delegate = self
    }

    func load(track: Track) {
        currentTrack = track
        service.load(track)
        publish(isPlaying: service.isPlaying, current: 0, duration: service.duration)
    }

    func playPause() {
        service.isPlaying ? service.pause() : service.play()
    }

    func seek(to ratio: Double) {
        guard ratio.isFinite, ratio >= 0, ratio <= 1 else { return }
        let target = (service.duration > 0 ? service.duration : 0) * ratio
        service.seek(to: target)
    }

    private func publish(isPlaying: Bool, current: TimeInterval, duration: TimeInterval) {
        guard let t = currentTrack else { return }
        let snap = Snapshot(title: t.title,
                            subtitle: t.subtitle,
                            isPlaying: isPlaying,
                            current: current,
                            duration: duration)
        delegate?.viewModelDidUpdate(snap)
    }
}

extension PlayerViewModel: PlayerServiceDelegate {
    func playerDidChange(isPlaying: Bool) {
        publish(isPlaying: isPlaying, current: service.currentTime, duration: service.duration)
    }

    func playerTimeDidUpdate(current: TimeInterval, duration: TimeInterval) {
        publish(isPlaying: service.isPlaying, current: current, duration: duration)
    }

    func playerDidEnd() {
        publish(isPlaying: false, current: service.duration, duration: service.duration)
    }
}
