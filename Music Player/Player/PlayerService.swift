//
//  PlayerService.swift
//  Embedded Music Player
//
//  Created by Konstantin Klyatskin on 2025-10-17.
//


// PlayerService.swift
import AVFoundation

final class PlayerService: NSObject, PlayerServiceProtocol {
    weak var delegate: PlayerServiceDelegate?

    private let player = AVPlayer()
    private var timeObserver: Any?
    private(set) var duration: TimeInterval = 0
    var isPlaying: Bool { player.rate > 0.0 }
    var currentTime: TimeInterval {
        CMTimeGetSeconds(player.currentTime())
    }

    func load(_ track: Track) {
        let item = AVPlayerItem(url: track.streamURL)
        removeTimeObserverIfNeeded()
        player.replaceCurrentItem(with: item)

        // Observe duration when ready
        item.asset.loadValuesAsynchronously(forKeys: ["duration"]) { [weak self] in
            guard let self else { return }
            let dur = CMTimeGetSeconds(item.asset.duration)
            self.duration = dur.isFinite ? max(dur, 0) : (track.durationHint ?? 0)
            DispatchQueue.main.async {
                self.delegate?.playerDidChange(isPlaying: self.isPlaying) // update duration label
            }
        }

        // Periodic time updates
        let interval = CMTime(seconds: 0.25, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        self.timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            let current = CMTimeGetSeconds(time)
            let dur = self.duration > 0 ? self.duration : CMTimeGetSeconds(self.player.currentItem?.duration ?? .zero)
            self.delegate?.playerTimeDidUpdate(current: max(0, current), duration: max(0, dur))
        }

        NotificationCenter.default.addObserver(self, selector: #selector(didEnd),
                                               name: .AVPlayerItemDidPlayToEndTime, object: item)
    }

    func play() { player.play(); delegate?.playerDidChange(isPlaying: true) }
    func pause() { player.pause(); delegate?.playerDidChange(isPlaying: false) }

    func seek(to seconds: TimeInterval) {
        let t = CMTime(seconds: max(0, seconds), preferredTimescale: 600)
        player.seek(to: t)
    }

    @objc private func didEnd() {
        delegate?.playerDidEnd()
    }

    private func removeTimeObserverIfNeeded() {
        if let obs = timeObserver {
            player.removeTimeObserver(obs)
            timeObserver = nil
        }
        NotificationCenter.default.removeObserver(self)
    }

    deinit { removeTimeObserverIfNeeded() }
}
