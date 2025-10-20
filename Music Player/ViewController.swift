//
//  ViewController.swift
//  Music Player
//
//  Created by Konstantin Klyatskin on 2025-10-17.
//

import UIKit

extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> Self {
        self.priority = priority
        return self
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemGray
        let vc = PlayerViewController()
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            vc.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            vc.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            // Maintain aspect ratio (width = height × ratio)
            vc.view.widthAnchor.constraint(equalTo: vc.view.heightAnchor, multiplier: Theme.Metrics.cardRatio / 1.5),
            // Fit within parent (maximum size)
            vc.view.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor),
            vc.view.heightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor),
            // Give it a preferred height so Auto Layout knows initial size for intrinsic content
//            vc.view.heightAnchor.constraint(equalToConstant: Theme.Metrics.cardHeight).withPriority(.defaultLow)
            vc.view.widthAnchor.constraint(equalToConstant: self.view.bounds.width).withPriority(.defaultLow)

        ])
        vc.didMove(toParent: self)
    }
}

