//
//  VideoPlayerView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-27.
//

import AVFoundation
import AVKit
import Combine
import SwiftUI

struct VideoPlayerView: View {
    let lesson: Lesson
    @Environment(\.dismiss) private var dismiss
    @StateObject private var playerViewModel = VideoPlayerViewModel()
    @State private var isFullScreen = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    headerView

                    videoPlayerSection
                        .frame(height: geometry.size.width * 9 / 16)

                    lessonDetailsSection

                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            playerViewModel.loadVideo(from: lesson.videoURL)
        }
        .onDisappear {
            playerViewModel.cleanup()
        }
        .fullScreenCover(isPresented: $isFullScreen) {
            FullScreenVideoView(player: playerViewModel.player)
        }
    }

    private var headerView: some View {
        HStack(spacing: 16) {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }

    private var videoPlayerSection: some View {
        ZStack {
            Color.black

            if let player = playerViewModel.player {
                ZStack {
                    VideoPlayer(player: player)

                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                isFullScreen = true
                            }) {
                                Image(
                                    systemName:
                                        "arrow.up.left.and.arrow.down.right"
                                )
                                .font(.title2)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                                .foregroundColor(.white)
                                .padding(12)
                            }
                        }
                    }
                }
            } else if playerViewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(Color(red: 0.4, green: 0.3, blue: 0.8))

                    Text("Loading video...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            } else if playerViewModel.hasError {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.white)

                    Text("Unable to load video")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)

                    if !playerViewModel.errorMessage.isEmpty {
                        Text(playerViewModel.errorMessage)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button("Try Again") {
                        playerViewModel.loadVideo(from: lesson.videoURL)
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.4, green: 0.3, blue: 0.8))
                    .cornerRadius(16)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "play.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.white)

                    Text("Video unavailable")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
        .cornerRadius(12)
        .padding(.horizontal, 24)
    }

    private var lessonDetailsSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(lesson.title)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)

                            Text(lesson.subtitle)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }

                    HStack(spacing: 24) {
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.system(size: 14))
                                .foregroundColor(
                                    Color(red: 0.4, green: 0.3, blue: 0.8))
                            Text("\(lesson.duration) min")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                        }

                        HStack(spacing: 6) {
                            Image(systemName: "flame")
                                .font(.system(size: 14))
                                .foregroundColor(
                                    Color(red: 0.4, green: 0.3, blue: 0.8))
                            Text("\(lesson.calories) cal")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                        }

                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                                .foregroundColor(
                                    Color(red: 0.4, green: 0.3, blue: 0.8))
                            Text(lesson.level)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 8)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("About This Lesson")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(lesson.description)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .lineSpacing(2)
                }

                if !lesson.equipment.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Equipment Needed")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(lesson.equipment, id: \.self) { equipment in
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(
                                            Color(
                                                red: 0.4, green: 0.3, blue: 0.8)
                                        )

                                    Text(equipment)
                                        .font(.system(size: 16))
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                }

                Color.clear.frame(height: 100)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
    }
}

//full screen video view
struct FullScreenVideoView: View {
    let player: AVPlayer?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
                    .onAppear {
                        player.play()
                    }
            }

            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

//view model
@MainActor
class VideoPlayerViewModel: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isLoading = false
    @Published var hasError = false
    @Published var errorMessage = ""

    private var cancellables = Set<AnyCancellable>()

    func loadVideo(from urlString: String) {
        guard !urlString.isEmpty else {
            hasError = true
            errorMessage = "Video URL is empty"
            return
        }

        print("Loading video from URL: \(urlString)")

        guard let videoURL = URL(string: urlString), videoURL.scheme != nil
        else {
            hasError = true
            errorMessage = "Invalid video URL format"
            return
        }

        isLoading = true
        hasError = false
        errorMessage = ""
        cleanup()

        if urlString.hasPrefix("http") {
            testURL(videoURL) { [weak self] success in
                DispatchQueue.main.async {
                    if success {
                        self?.configureAudioSession()
                        self?.createPlayer(with: videoURL)
                    } else {
                        self?.hasError = true
                        self?.isLoading = false
                        self?.errorMessage = "Video URL is not accessible"
                    }
                }
            }
        } else {
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
        let asset = AVURLAsset(url: url)
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

                if playableStatus == .loaded && tracksStatus == .loaded {
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
                        .receive(on: DispatchQueue.main)
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
                        .store(in: &self.cancellables)

                } else {
                    self.hasError = true
                    self.isLoading = false
                    self.errorMessage = "Unable to prepare video for playback"
                }
            }
        }
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error.localizedDescription)")
        }
    }

    func cleanup() {
        player?.pause()
        player = nil
        cancellables.removeAll()
        try? AVAudioSession.sharedInstance().setActive(
            false, options: .notifyOthersOnDeactivation)
    }
}

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView(lesson: Lesson.sampleLessons[0])
    }
}
