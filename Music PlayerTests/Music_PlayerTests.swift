//
//  Embedded_Music_PlayerTests.swift
//  Embedded Music PlayerTests
//
//  Created by Konstantin Klyatskin on 2025-10-17.
//

import XCTest
@testable import Music_Player

final class Embedded_Music_PlayerTests: XCTestCase {

    
    final class MockService: PlayerServiceProtocol {
          weak var delegate: PlayerServiceDelegate?
          var isPlaying = false
          var duration: TimeInterval = 100
          var currentTime: TimeInterval = 0
          func load(_ track: Track) {}
          func play() { isPlaying = true; delegate?.playerDidChange(isPlaying: true) }
          func pause() { isPlaying = false; delegate?.playerDidChange(isPlaying: false) }
          func seek(to seconds: TimeInterval) { currentTime = seconds; delegate?.playerTimeDidUpdate(current: seconds, duration: duration) }
      }

      func testPlayPauseToggles() {
          let mock = MockService()
          let vm = PlayerViewModel(service: mock)
          let t = Track(title: "t", subtitle: "s", artworkURL: nil, streamURL: URL(string: "https://a.com")!, durationHint: 100)
          vm.load(track: t)
          vm.playPause()
          XCTAssertTrue(mock.isPlaying)
          vm.playPause()
          XCTAssertFalse(mock.isPlaying)
      }
}
