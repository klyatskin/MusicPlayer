//
//  PlayerViewController.swift
//  Embedded Music Player
//
//  Created by Konstantin Klyatskin on 2025-10-17.
//

// PlayerViewController.swift
import UIKit

final class PlayerViewController: UIViewController {
    private let card = PlayerCardView()
    private let vm: PlayerViewModel

    init() {
        let service = PlayerService()
        self.vm = PlayerViewModel(service: service)
        super.init(nibName: nil, bundle: nil)
        vm.delegate = self
    }
    required init?(coder: NSCoder) { fatalError() }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        view.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            card.topAnchor.constraint(equalTo: view.topAnchor),
            card.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Bind user actions
        card.onPlayPause = { [weak self] in
            self?.vm.playPause()
        }
        card.onSeekRatio = { [weak self] ratio in self?.vm.seek(to: ratio) }
        card.onNext = { print("onNext") }
        card.onPrev = { print("onPrev") }
        card.onLike = { print("onLike") }
        card.onRepeat = { isEnabled in print("onRepeat: \(isEnabled)") }
        
        vm.load(track: Track.sampleTrack)
        self.card.setArtwork(UIImage.placeholderArtwork())
        loadArtwork(from: Track.sampleTrack.artworkURL)
    }
    
    private func loadArtwork(from url: URL) {
        var req = URLRequest(url: url)
        req.timeoutInterval = 10
        URLSession.shared.dataTask(with: req) { [weak self] data, response, error in
            guard let self else { return }
            if let error = error {
                print("Artwork load error:", error.localizedDescription)
                DispatchQueue.main.async { self.card.setArtwork(UIImage.placeholderArtwork()) }
                return
            }
            guard
                let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode),
                let data = data,
                let image = UIImage(data: data)
            else {
                DispatchQueue.main.async { self.card.setArtwork(UIImage.placeholderArtwork()) }
                return
            }
            DispatchQueue.main.async {
                self.card.setArtwork(image)
            }
        }.resume()
    }

    
}

extension PlayerViewController: PlayerViewModelDelegate {
    func viewModelDidUpdate(_ s: PlayerViewModel.Snapshot) {
        card.update(title: s.title,
                    subtitle: s.subtitle,
                    isPlaying: s.isPlaying,
                    current: s.current,
                    duration: s.duration)
    }
}
