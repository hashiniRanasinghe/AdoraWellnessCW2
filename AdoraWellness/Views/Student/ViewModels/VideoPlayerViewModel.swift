//
//  VideoPlayerViewModel.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-09-16.
//

import AVFoundation
import AVKit
import Combine
import SwiftUI

//view model
@MainActor
class VideoPlayerViewModel: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isLoading = false
    @Published var hasError = false
    @Published var errorMessage = ""

    private var cancellables = Set<AnyCancellable>()

    //load a video using a URL
    func loadVideo(from urlString: String) {
        guard !urlString.isEmpty else {
            hasError = true
            errorMessage = "Video URL is empty"
            return
        }

        print("loading video from URL: \(urlString)")

        //convert string to URL
        guard let videoURL = URL(string: urlString), videoURL.scheme != nil  //ensures the URL has a scheme like http, https, file
        else {
            hasError = true
            errorMessage = "Invalid video URL format"
            return
        }

        isLoading = true
        hasError = false
        errorMessage = ""
        cleanup()
        //check if the video file is online or not
        if urlString.hasPrefix("http") {
            //call the helper to validate the url and return true or false
            testURL(videoURL) { [weak self] success in
                DispatchQueue.main.async {
                    if success {
                        self?.configureAudioSession()  //configure AVAudioSession
                        self?.createPlayer(with: videoURL)
                    } else {
                        self?.hasError = true
                        self?.isLoading = false
                        self?.errorMessage = "Video URL is not accessible"
                    }
                }
            }
        } else {
            //if the URL is not remote, skip the network test and create a player immediately
            configureAudioSession()
            createPlayer(with: videoURL)
        }
    }

    private func testURL(_ url: URL, completion: @escaping (Bool) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                completion(httpResponse.statusCode == 200)
            } else {
                completion(error == nil)
            }
        }
        task.resume()
    }

    private func createPlayer(with url: URL) {
        let asset = AVURLAsset(url: url)  //AVFoundation representation of a media resource
        //fetch information about these keys- playable and tracks
        asset.loadValuesAsynchronously(forKeys: ["playable", "tracks"]) {
            [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }

                var error: NSError?
                let playableStatus = asset.statusOfValue(
                    forKey: "playable", error: &error)
                let tracksStatus = asset.statusOfValue(
                    forKey: "tracks", error: &error)

                if let loadError = error {
                    self.hasError = true
                    self.isLoading = false
                    self.errorMessage =
                        "Failed to load video: \(loadError.localizedDescription)"
                    return
                }

                //continue if both the playable info and the tracks info loaded successfully
                if playableStatus == .loaded && tracksStatus == .loaded {
                    //if the file is not playable OR there are no video tracks, then error
                    if !asset.isPlayable
                        || asset.tracks(withMediaType: .video).isEmpty
                    {
                        self.hasError = true
                        self.isLoading = false
                        self.errorMessage =
                            "Video not playable or no video tracks found"
                        return
                    }

                    let playerItem = AVPlayerItem(asset: asset)
                    self.player = AVPlayer(playerItem: playerItem)

                    playerItem.publisher(for: \.status)
                        //video events can come from bg threads but UI updates must happen on main thread.
                        .receive(on: DispatchQueue.main)
                        //handle the status updates
                        .sink { [weak self] status in
                            switch status {
                            case .readyToPlay:
                                self?.isLoading = false
                                self?.hasError = false
                                self?.errorMessage = ""
                            case .failed:
                                self?.isLoading = false
                                self?.hasError = true
                                self?.errorMessage =
                                    playerItem.error?.localizedDescription
                                    ?? "Unknown playback error"
                            default: break
                            }
                        }
                        //keeps the subscription alive as long as the view model exist
                        .store(in: &self.cancellables)

                } else {
                    self.hasError = true
                    self.isLoading = false
                    self.errorMessage = "Unable to prepare video for playback"
                }
            }
        }
    }

    //before playing video, configure the iPhone’s audio system (AVAudioSession)
    private func configureAudioSession() {
        do {
            //gives the global audio session on iOS - control how app interacts with other sounds on the device
            try AVAudioSession.sharedInstance().setCategory(
                //media playback,gnores the mute switch sts and doesn’t mix with other apps sounds
                .playback, mode: .moviePlayback)  //sub-mode optimized for watching video.
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error.localizedDescription)")
        }
    }

    func cleanup() {
        player?.pause()
        player = nil
        //cancel all Combine subscriptions
        cancellables.removeAll()
        try? AVAudioSession.sharedInstance().setActive(
            false, options: .notifyOthersOnDeactivation)  //deactivates audio session and tells iOS to give audio back to other apps
    }
}
